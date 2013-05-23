class AddMoneyFlowIndexToStockPrice < ActiveRecord::Migration
  def change
    add_column :stock_prices, :money_flow_index, :float
  end
end
