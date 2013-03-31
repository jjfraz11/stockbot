require  Rails.root.join('app', 'scrapers', 'stock_price_scraper').to_s

class StockPrice < ActiveRecord::Base
  attr_accessible :adj_close, :close, :date, :high, :low, :open, :symbol, :volume

  def something?
  end


  def build_database(options = {start_from: '2012-01-01'})
    found = 0
    end_date    = Date.today.strftime('%Y-%m-%d') 
    report_type = 'day'
    rows        = []

    SP500_Stock.find(:all).each do |stock| 
      if stock.sp500_added_date.empty?
        start_date  = options[:start_from]
      else
        start_date = stock.sp500_added_date
        found += 1
      end
      
      stock_prices = StockPriceScraper.new( stock.symbol, start_date, end_date, report_type
                                             ).scrape(model: self)
      p "#{symbol} - #{stock_prices.size}"
      rows << stock_prices
    end
  end    


end
