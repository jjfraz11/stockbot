require Rails.root.join('lib','stats').to_s
word = Rails.root.join('app','scrapers','stock_price_scraper').to_s
puts word
require word

class StockPriceBuilder < Builder
  def initialize(options = {})
    @model = StockPrice
    @options = options
  end

  def build(opts = {})
    options = {
      stock_model:              Sp500Stock, 
      start_date:               '2011-01-11',
      end_date:                 Date.today.strftime('%Y-%m-%d'),
      added_date_sym:           :sp500_added_date,
      n_days_bollinger_bands:   20,
      n_days_relative_strength: 9,
      n_days_money_flow:        5
    }.merge(opts)
    missing_stocks = []

    stocks = options[:stock_model].all
    if stocks.empty?
      options[:stock_model].build_database
      stocks = options[:stock_model].all
      raise NoDataError, "#{options[:stock_model]} has no data." if stocks.empty? 
    end

    ##### Loop through collection of stocks and gather data for each symbol
    stocks.each do |stock|
      #### Set temp start date based on date_method if provided
      if ( stock.send(options[:added_date_sym]).nil? or
           stock.send(options[:added_date_sym]) < options[:start_date].to_date )
        start_date  = options[:start_date]
      else
        start_date = stock.send(options[:added_date_sym])
      end

      ##### Scrape Basic Stock Data #####
      stock_prices = scrape_stock_data(stock, start_date, options[:end_date])
      
      ##### Add Stock Signal Attributes #####
      add_bollinger_bands(stock.symbol, options)
      
      add_relative_strength_index(stock.symbol, options)

      add_money_flow_index(stock.symbol, options)

      puts "#{stock.symbol.ljust(5)} - #{stock_prices.size.to_s.rjust(4)} added."
      missing_stocks << stock.symbol if stock_prices.empty?
    end
    puts "Missing Stocks: #{missing_stocks.join(', ')}" unless missing_stocks.empty?
    puts "Built Stock Prices database."
  end 


  ##### Coupled to stock object which requires a symbol method
  ##### This is done to enable savign the corrected stock names to the database
  def scrape_stock_data(stock, start_date, end_date)
    report_type = 'day'
    begin
      stock_prices = StockPriceScraper.new( stock.symbol,
                                             start_date,
                                             end_date,
                                             report_type ).scrape(model: @model)
    rescue Scraper::ScraperDataError => e
      puts e.message
      stock.symbol.gsub!(".", "-")
      puts "Retrying with: #{stock.symbol}"
      stock_prices = StockPriceScraper.new( stock.symbol,
                                            start_date,
                                            end_date,
                                            report_type ).scrape(model: @model)
      stock.save unless stock_prices.empty?
    end
    stock_prices
  end

  
  def add_bollinger_bands(symbol, options = {})
    options = { :num_days => options } if options.is_a? Fixnum
    options = {
      :start_date => @model.where(:symbol => symbol).order("date asc").limit(1).first.date,
      :end_date   => @model.where(:symbol => symbol).order("date desc").limit(1).first.date,
      :num_days   => 20
    }.merge(options)

    values = []
    stock_prices = []
    stock_data = stock_data_with_trailing_days(symbol, options)

    stock_data.reverse_each do |stock_price|
      unless values.size < options[:num_days]
        stock_price.mavg   = values.mean.round(2)
        stock_price.stddev = values.deviation.round(8)
        stock_price.save

        stock_prices << stock_price
        values.shift
      end
      values << stock_price.close
    end
    stock_prices
  end

  def add_relative_strength_index(symbol, options = {})
    options = { :num_days => options } if options.is_a? Fixnum
    options = {
      :start_date => @model.where(:symbol => symbol).order("date asc").limit(1).first.date,
      :end_date   => @model.where(:symbol => symbol).order("date desc").limit(1).first.date,
      :num_days   => 9
    }.merge(options)

    values         = []
    stock_prices   = []
    stock_data     = stock_data_with_trailing_days(symbol, options)
    previous_close = stock_data.pop.close

    stock_data.reverse_each do |stock_price|
      if values.size < options[:num_days]
        values << ( stock_price.close - previous_close ) unless previous_close.nil?
      else
        up_periods =  values.collect { |e| if e > 0 then e else 0 end }
        down_periods = values.collect { |e| if e < 0 then e.abs else 0 end }
        rs = up_periods.ema.first / down_periods.ema.first
        stock_price.relative_strength_index = ( 100 - ( 100 / ( 1 + rs ) ) )
        # p values, up_periods, down_periods, stock_price.rsi
        stock_price.save
        stock_prices << stock_price

        values.shift
        values <<  ( stock_price.close - previous_close)
      end
      previous_close = stock_price.close
    end
    stock_prices
  end

  def add_money_flow_index(symbol, options = {})
    options = { :num_days => options } if options.is_a? Fixnum
    options = {
      :start_date => @model.where(:symbol => symbol).order("date asc").limit(1).first.date,
      :end_date   => @model.where(:symbol => symbol).order("date desc").limit(1).first.date,
      :num_days   => 5
    }.merge(options)

    values                 = []
    stock_prices           = []
    stock_data             = stock_data_with_trailing_days(symbol, options)
    previous_typical_price = stock_data.pop.typical_price
    stock_data.reverse_each do |stock_price|
      if values.size < options[:num_days]
        values << [ 
                   ( stock_price.typical_price - previous_typical_price ), 
                   stock_price.raw_money_flow 
                  ] unless previous_typical_price.nil?
      else
        positive_money_flow = values.collect { |e| if e[0] > 0 then e[1] else 0 end }.sum
        negative_money_flow = values.collect { |e| if e[0] < 0 then e[1].abs else 0 end }.sum
        money_flow_index = 100 * ( positive_money_flow / 
                                   ( positive_money_flow + negative_money_flow ) )
        # p positive_money_flow, negative_money_flow, money_flow_index
        stock_price.money_flow_index = money_flow_index
        stock_price.save
        stock_prices << stock_price

        values.shift
        values << [
                   ( stock_price.typical_price - previous_typical_price ),
                   stock_price.raw_money_flow
                  ]
      end
      previous_typical_price = stock_price.typical_price
    end
   stock_prices
  end



  def stock_data_with_trailing_days(symbol, options = {})
    options = { :num_days => options } if options.is_a? Fixnum      
    options = {
      :start_date => @model.where(:symbol => symbol).order("date asc").limit(1).first.date,
      :end_date   => @model.where(:symbol => symbol).order("date desc").limit(1).first.date,
      :num_days   => 0
    }.merge(options)

    stock_data = @model.
      where(:symbol => symbol, 
            :date => ( options[:start_date].to_date )..( options[:end_date].to_date) ).
      order("date desc")
    stock_data += @model.
      where( "symbol = ? and date < ?", symbol, options[:start_date].to_date ).
      order("date desc").limit(options[:num_days])

    stock_data
  end
  
end
