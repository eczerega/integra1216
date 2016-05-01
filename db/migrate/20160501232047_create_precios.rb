class CreatePrecios < ActiveRecord::Migration
  def change
    create_table :precios do |t|
      t.string :SKU
      t.string :Descripción
      t.integer :Precio_Unitario

      t.timestamps null: false
    end
  end
end
