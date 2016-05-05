class CreateFacturaOcs < ActiveRecord::Migration
  def change
    create_table :factura_ocs do |t|
      t.string :factura_id
      t.string :oc_id
      t.string :estado

      t.timestamps null: false
    end
  end
end
