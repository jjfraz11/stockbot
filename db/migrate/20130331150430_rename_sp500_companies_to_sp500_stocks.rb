class RenameSp500CompaniesToSp500Stocks < ActiveRecord::Migration
  def up
    rename_table :sp500_companies, :sp500_stocks
  end

  def down
    rename_table :sp500_stocks, :sp500_companies
  end
end
