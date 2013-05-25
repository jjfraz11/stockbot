class Sp500Stock < ActiveRecord::Base
  attr_accessible :company_name, :gics_sector, :gics_sub_industry, :headquarters_city, :sec_filings, :sp500_added_date, :symbol

  validates :symbol, :uniqueness => true

  def Sp500Stock.build_database
    builder = Sp500StockBuilder.new
    builder.build
  end
end
