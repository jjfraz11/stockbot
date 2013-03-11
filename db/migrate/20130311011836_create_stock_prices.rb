class CreateStockPrices < ActiveRecord::Migration
  def change
    create_table :stock_prices do |t|
      t.string :symbol
      t.date :date
      t.float :high
      t.float :low
      t.integer :volume
      t.float :open
      t.float :close
      t.float :adj_close

      t.timestamps
    end
  end
end
