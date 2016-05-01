class CreateProduccions < ActiveRecord::Migration
  def change
    create_table :produccions do |t|
      t.string :id_dev
      t.string :created_at_dev
      t.date :fecha_termino

      t.timestamps null: false
    end
  end
end
