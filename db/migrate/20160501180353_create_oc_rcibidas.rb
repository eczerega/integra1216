class CreateOcRcibidas < ActiveRecord::Migration
  def change
    create_table :oc_rcibidas do |t|
      t.string :id_dev
      t.date :created_at_dev
      t.string :canal
      t.string :sku
      t.integer :cantidad
      t.integer :precio_unit
      t.date :entrega_at
      t.date :despacho_at
      t.string :estado
      t.string :rechazo
      t.string :anulacion
      t.string :notas
      t.string :id_factura_dev

      t.timestamps null: false
    end
  end
end
