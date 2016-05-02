class CreateSkuStocks < ActiveRecord::Migration
  def change
    create_table :sku_stocks do |t|
      t.string :SKU
      t.integer :stock

      t.timestamps null: false
    end
  end
end
