class Sp500Stock < ActiveRecord::Base
  attr_accessible :company_name, :gics_sector, :gics_sub_industry, :headquarters_city, :sec_filings, :sp500_added_date, :symbol

  validates :symbol, :uniqueness => true

  def self.build_database
    sp500_stocks = Sp500StockScraper.new.scrape( model: Sp500Stock )
    puts "Built SP500 database. #{sp500_stocks.size} stocks scraped."
  end
end
