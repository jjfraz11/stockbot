class StockPrice < ActiveRecord::Base
  class NoDataError < RuntimeError; end

  belongs_to :sp_500_stock

  attr_accessible :adj_close, :close, :date, :high, :low, :open, :symbol, :volume

  validates :symbol, :uniqueness => { :scope => :date,
    :message => "Only one stock price per symbol each day." }

  def typical_price
    ( high + low + close ) / 3
  end

  def raw_money_flow
    typical_price * volume
  end

  def build_database
    builder = StockPriceBuilder.new
    builder.build
  end
end
