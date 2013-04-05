require Rails.root.join('lib','stats').to_s

class StockPrice < ActiveRecord::Base
  attr_accessible :adj_close, :close, :date, :high, :low, :open, :symbol, :volume

  validates :symbol, :uniqueness => { :scope => :date,
    :message => "Only one stock price per symbol each day." }

  def StockPrice.bollinger_bands(symbol, options = {})
    options = {
      :start_date => StockPrice.where(:symbol => symbol).order("date asc").limit(1).first.date,
      :end_date   => StockPrice.where(:symbol => symbol).order("date desc").limit(1).first.date,
      :num_days   => 20
    }.merge(options)

    stock_data = StockPrice.
      where(:symbol => symbol, 
            :date => ( options[:start_date].to_date )..( options[:end_date].to_date) ).
      order("date desc")
    stock_data += StockPrice.
      where( "symbol = ? and date < ?", symbol, options[:start_date].to_date ).
      order("date desc").limit(options[:num_days])

    values = []
    result = {}
    stock_data.reverse_each do |stock_price|
      if values.size < options[:num_days]
        values << stock_price.close
      else
        result[stock_price.date.to_s] = [ values.mean.round(2), values.deviation.round(8) ]
        values.shift
        values << stock_price.close
      end
    end
    result
  end
end
