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
end


s = SP500StocksScraper.new
p s.data_url
p s.scrape[0..9]
# s.symbol = 'GOOG'
# p s.data_url
# p s.scrape
