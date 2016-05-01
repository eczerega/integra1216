class OrdersController < ApplicationController

	  layout false

	def index
	end


end
#rails g scaffold oc_recibidas id_dev:string created_at_dev:date canal:string sku:string cantidad:integer precio_unit:integer entrega_at:date despacho_at:date estado:string rechazo:string anulacion:string notas:string id_factura_dev:string