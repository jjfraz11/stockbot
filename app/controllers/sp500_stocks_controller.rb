class Sp500StocksController < ApplicationController
  # GET /sp500_stocks
  # GET /sp500_stocks.json
  def index
    @sp500_stocks = Sp500Stock.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sp500_stocks }
    end
  end

  # GET /sp500_stocks/1
  # GET /sp500_stocks/1.json
  def show
    @sp500_stock = Sp500Stock.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sp500_stock }
    end
  end

  # GET /sp500_stocks/new
  # GET /sp500_stocks/new.json
  def new
    @sp500_stock = Sp500Stock.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sp500_stock }
    end
  end

  # GET /sp500_stocks/1/edit
  def edit
    @sp500_stock = Sp500Stock.find(params[:id])
  end

  # POST /sp500_stocks
  # POST /sp500_stocks.json
  def create
    @sp500_stock = Sp500Stock.new(params[:sp500_stock])

    respond_to do |format|
      if @sp500_stock.save
        format.html { redirect_to @sp500_stock, notice: 'Sp500 stock was successfully created.' }
        format.json { render json: @sp500_stock, status: :created, location: @sp500_stock }
      else
        format.html { render action: "new" }
        format.json { render json: @sp500_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sp500_stocks/1
  # PUT /sp500_stocks/1.json
  def update
    @sp500_stock = Sp500Stock.find(params[:id])

    respond_to do |format|
      if @sp500_stock.update_attributes(params[:sp500_stock])
        format.html { redirect_to @sp500_stock, notice: 'Sp500 stock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sp500_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sp500_stocks/1
  # DELETE /sp500_stocks/1.json
  def destroy
    @sp500_stock = Sp500Stock.find(params[:id])
    @sp500_stock.destroy

    respond_to do |format|
      format.html { redirect_to sp500_stocks_url }
      format.json { head :no_content }
    end
  end

  def build_database
    Sp500StockScraper.new.scrape( model: Sp500Stock )
  end
end
