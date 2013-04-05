require Rails.root.join('lib','stats').to_s

class StockPrice < ActiveRecord::Base
  attr_accessible :adj_close, :close, :date, :high, :low, :open, :symbol, :volume

  validates :symbol, :uniqueness => { :scope => :date,
    :message => "Only one stock price per symbol each day." }

  def self.build_database(options = {})
    options = {
      start_date: '2011-01-11',
      end_date:   Date.today.strftime('%Y-%m-%d')
    }.merge(options)
    missing_stocks = []

    ##### This should be decoupled from the Sp500 stock model
    ##### Should accept any collection of stocks that have a
    ##### added_date and symbol.

    ##### Loop through collection of stocks and gather data for each symbol
    Sp500Stock.all.each do |stock|
      if ( stock.sp500_added_date.nil? or
           stock.sp500_added_date < options[:start_date].to_date )
        start_date  = options[:start_date]
      else
        start_date = stock.sp500_added_date
      end

      ##### Scrape Basic Stock Data #####
      stock_prices = scrape_stock_data(stock, options[:start_date], options[:end_date])
      
      ##### Add Stock Bollinger Bands #####
      add_bollinger_bands(stock.symbol, :num_days => 20)
      
      puts "Added: #{stock.symbol.ljust(5)}" + 
        " - #{stock_prices.size.to_s.rjust(4)} days of data."
      missing_stocks << stock.symbol if stock_prices.empty?
    end
    puts "Missing Stocks: #{missing_stocks.join(', ')}" unless missing_stocks.empty?
    puts "Built Stock Prices database."
  end 


  ##### Coupled to stock object which requires a symbol method
  ##### This is done to enable savign the corrected stock names to the database
  def self.scrape_stock_data(stock, start_date, end_date)
    report_type = 'day'
    begin
      stock_prices = StockPricesScraper.new( stock.symbol,
                                             start_date,
                                             end_date,
                                             report_type ).scrape(model: self)
    rescue Scraper::ScraperDataError => e
      puts e.message
      stock.symbol.gsub!(".", "-")
      puts "Retrying with: #{stock.symbol}"
      stock_prices = StockPricesScraper.new( stock.symbol,
                                             start_date,
                                             end_date,
                                             report_type ).scrape(model: self)
      stock.save unless stock_prices.empty?
    end
    stock_prices
  end

  
  def self.add_bollinger_bands(symbol, options = {})
    options = {
      :start_date => self.where(:symbol => symbol).order("date asc").limit(1).first.date,
      :end_date   => self.where(:symbol => symbol).order("date desc").limit(1).first.date,
      :num_days   => 20
    }.merge(options)

    stock_data = self.
      where(:symbol => symbol, 
            :date => ( options[:start_date].to_date )..( options[:end_date].to_date) ).
      order("date desc")
    stock_data += self.
      where( "symbol = ? and date < ?", symbol, options[:start_date].to_date ).
      order("date desc").limit(options[:num_days])

    values = []
    stock_prices = []
    stock_data.reverse_each do |stock_price|
      if values.size < options[:num_days]
        values << stock_price.close
      else        
        stock_price.mavg_20   = values.mean.round(2)
        stock_price.stddev_20 = values.deviation.round(8)
        stock_price.save
        stock_prices << stock_price

        values.shift
        values << stock_price.close
      end
    end
    stock_prices
  end

end
