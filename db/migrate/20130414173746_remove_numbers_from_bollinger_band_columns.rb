class RemoveNumbersFromBollingerBandColumns < ActiveRecord::Migration
  def up
    rename_column :stock_prices, :mavg_20, :mavg
    rename_column :stock_prices, :stddev_20, :stddev
  end

  def down
    rename_column :stock_prices, :mavg, :mavg_20
    rename_column :stock_prices, :stddev, :stddev_20
  end
end
