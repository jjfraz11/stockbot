class AddStddev20ToStockPrices < ActiveRecord::Migration
  def change
    add_column :stock_prices, :stddev_20, :float
  end
end
