class CreateTiempos < ActiveRecord::Migration
  def change
    create_table :tiempos do |t|
      t.string :SKU
      t.string :Descripción
      t.string :Tipo
      t.integer :Grupo_Proyecto
      t.string :Unidades
      t.integer :Costo_produccion_unitario
      t.integer :Lote_Produccion
      t.float :Tiempo_Medio_Producción

      t.timestamps null: false
    end
  end
end
