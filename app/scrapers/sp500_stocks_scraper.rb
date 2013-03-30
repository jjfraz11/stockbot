require_relative 'scraper'

class SP500StocksScraper < Scraper

  class ReportTypeError < RuntimeError; end

  TABLE_CLASS  = 'wikitable sortable jquery-tablesorter'
  HEADER_CLASS = 'headerSort'
  DATA_CLASS   = nil
  ROW_SIZE     = 7

  def initialize()
    super()
  end

  def base_url
    "http://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
  end

  def get_rows
    table_xpath = '//table[@class="wikitable sortable"]'
    table_index = 0
    table = get_page.search(table_xpath)[table_index]
    rows = table.search('.//tr')
  end

  def clean_row(row)
    out_row = {}
    out_row[:symbol]            = row[:ticker_symbol]
    out_row[:company_name]      = row[:company]
    out_row[:sec_filings]       = row[:sec_filings]
    out_row[:gics_sector]       = row[:gics_sector]
    out_row[:gics_sub_industry] = row[:gics_sub_industry]
    out_row[:headquarters_city] = row[:address_of_headquarters]
    out_row[:sp500_added_date]  = row[:date_first_added]
    out_row
  end
end


s = SP500StocksScraper.new
p s.data_url
row = s.scrape.select do |row|
  ! row[:sp500_added_date].empty?
end[0..2]
p row

# s.symbol = 'GOOG'
# p s.data_url
# p s.scrape
