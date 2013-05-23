class AddRsiToStockPrices < ActiveRecord::Migration
  def change
    add_column :stock_prices, :relative_strength_index, :float
  end
end
