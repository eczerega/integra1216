class CreateCostos < ActiveRecord::Migration
  def change
    create_table :costos do |t|
      t.string :SKU
      t.string :Descripcion
      t.integer :Lote
      t.string :Unidad
      t.string :SKU_Ingrediente
      t.string :Ingrediente
      t.integer :Requerimiento
      t.string :Unidad
      t.string :Ingrediente
      t.integer :Precio_Ingrediente

      t.timestamps null: false
    end
  end
end
