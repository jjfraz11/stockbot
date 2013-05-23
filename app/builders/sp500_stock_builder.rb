class Sp500StockBuilder < Builder
  def initialize
    @model = Sp500Stock
  end

  def build
    sp500_stocks = Sp500StockScraper.new.scrape( model: @model )
    puts "Built SP500 database. #{sp500_stocks.size} stocks scraped."
  end
end
