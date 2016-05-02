class AddData2Orders < ActiveRecord::Migration
  def change
    add_column :oc_recibidas, :cliente, :string
    add_column :oc_recibidas, :proveedor, :string
    add_column :oc_recibidas, :fechaEntrega, :integer
  end
end
