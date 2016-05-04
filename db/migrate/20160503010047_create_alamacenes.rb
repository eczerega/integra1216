class CreateAlamacenes < ActiveRecord::Migration
  def change
    create_table :alamacenes do |t|
      t.string :almacenid
      t.integer :tamano

      t.timestamps null: false
    end
  end
end
