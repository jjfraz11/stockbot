class CreateSp500Companies < ActiveRecord::Migration
  def change
    create_table :sp500_companies do |t|
      t.string :symbol
      t.string :company_name
      t.string :sec_filings
      t.string :gics_sector
      t.string :gics_sub_industry
      t.string :headquarters_city
      t.date :sp500_added_date

      t.timestamps
    end
  end
end
