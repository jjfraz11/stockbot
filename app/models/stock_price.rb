class StockPrice < ActiveRecord::Base
  attr_accessible :adj_close, :close, :date, :high, :low, :open, :symbol, :volume

  validates :symbol, :uniqueness => { :scope => :date,
    :message => "Only one stock price per symbol each day." }

  def StockPrice.bollinger_bands(symbol, options = {})
    options = {
      :start_date => Date.today - 7,
      :end_date   => Date.today - 1,
      :num_days   => 4
    }.merge(options)

    stock_data = StockPrice.
      where(:symbol => symbol, 
            :date => ( options[:start_date].to_date )..( options[:end_date].to_date) ).
      order("date desc")

    p stock_data.collect { |sp| sp.date.to_s }

    stock_data += StockPrice.
      where( "symbol = ? and date < ?", symbol, options[:start_date].to_date ).
      order("date desc").limit(options[:num_days])

    p stock_data.collect { |sp| sp.date.to_s }
    n     = 0
    total = 0
    p_avg = 0
    values = []
    stock_data.reverse_each do |stock_price|
      n     += 1
      total += stock_price.close
      avg = ( total / n )

      if values.size < options[:num_days]
        values << stock_price.close
        p "#{stock_price.date.to_s} - #{values}"
      else
        m_avg = values.inject(:+) / values.size
        values.shift
        values << stock_price.close
        p "#{stock_price.date.to_s} - #{values} - #{t2}"
      end

      p "#{n.to_s.rjust(3)}" +
        " - #{stock_price.date.to_s.ljust(10)}" +
        " - #{stock_price.close.round(2).to_s.rjust(6)}" +
        " - #{p_avg.round(2).to_s.rjust(8)}" +
        " - #{total.round(2).to_s.rjust(8)}" +
        " - #{avg.round(2).to_s.rjust(8)}"
      p_avg = avg
    end
    "Done"
  end
end
