class AddMavg20ToStockPrices < ActiveRecord::Migration
  def change
    add_column :stock_prices, :mavg_20, :float
  end
end
