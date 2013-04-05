require Rails.root.join('app', 'scrapers', 'stock_prices_scraper').to_s

class StockPricesController < ApplicationController
  # GET /stock_prices
  # GET /stock_prices.json
  def index
    @stock_prices = StockPrice.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stock_prices }
    end
  end

  # GET /stock_prices/1
  # GET /stock_prices/1.json
  def show
    @stock_price = StockPrice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock_price }
    end
  end

  # GET /stock_prices/new
  # GET /stock_prices/new.json
  def new
    @stock_price = StockPrice.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stock_price }
    end
  end

  # GET /stock_prices/1/edit
  def edit
    @stock_price = StockPrice.find(params[:id])
  end

  # POST /stock_prices
  # POST /stock_prices.json
  def create
    @stock_price = StockPrice.new(params[:stock_price])

    respond_to do |format|
      if @stock_price.save
        format.html { redirect_to @stock_price, notice: 'Stock price was successfully created.' }
        format.json { render json: @stock_price, status: :created, location: @stock_price }
      else
        format.html { render action: "new" }
        format.json { render json: @stock_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stock_prices/1
  # PUT /stock_prices/1.json
  def update
    @stock_price = StockPrice.find(params[:id])

    respond_to do |format|
      if @stock_price.update_attributes(params[:stock_price])
        format.html { redirect_to @stock_price, notice: 'Stock price was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stock_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_prices/1
  # DELETE /stock_prices/1.json
  def destroy
    @stock_price = StockPrice.find(params[:id])
    @stock_price.destroy

    respond_to do |format|
      format.html { redirect_to stock_prices_url }
      format.json { head :no_content }
    end
  end

  def self.build_database(options = {start_date: '2013-01-01'})
    end_date    = Date.today.strftime('%Y-%m-%d') 
    report_type = 'day'
    missing_stocks = []

    Sp500Stock.all.each do |stock|
      if ( stock.sp500_added_date.nil? or
           stock.sp500_added_date < options[:start_date].to_date )
        start_date  = options[:start_date]
      else
        start_date = stock.sp500_added_date
      end
      
      begin
        stock_prices = StockPricesScraper.new( stock.symbol,
                                               start_date,
                                               end_date,
                                               report_type ).scrape(model: StockPrice)
      rescue Scraper::ScraperDataError => e
        puts e.message
        fix_symbol = stock.symbol.gsub(".", "-")
        puts "Retrying with: #{fix_symbol}"
        stock_prices = StockPricesScraper.new( fix_symbol,
                                               start_date,
                                               end_date,
                                               report_type ).scrape(model: StockPrice)
      end
      
      puts "Added: #{stock.symbol.ljust(5)}" + 
        " - #{stock_prices.size.to_s.rjust(4)} days of data."
      missing_stocks << stock.symbol if stock_prices.empty?
    end
    puts "Missing Stocks: #{missing_stocks.join(', ')}" unless missing_stocks.empty?
    puts "Built Stock Prices database."
  end 

end
