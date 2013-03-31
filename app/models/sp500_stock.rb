class Sp500Stock < ActiveRecord::Base
  attr_accessible :company_name, :gics_sector, :gics_sub_industry, :headquarters_city, :sec_filings, :sp500_added_date, :symbol
end
