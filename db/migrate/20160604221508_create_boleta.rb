class CreateBoleta < ActiveRecord::Migration
  def change
    create_table :boleta do |t|
      t.string :id_boleta
      t.string :estado
      t.integer :cantidad7
      t.integer :cantidad15
      t.integer :cantidad30
      t.integer :cantidad34
      t.integer :cantidad51
      t.string :cliente
      t.string :direccion

      t.timestamps null: false
    end
  end
end
