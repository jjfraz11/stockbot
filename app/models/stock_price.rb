class StockPrice < ActiveRecord::Base
  attr_accessible :adj_close, :close, :date, :high, :low, :open, :symbol, :volume
end
