json.array!(@oc_recibidas) do |oc_recibida|
  json.extract! oc_recibida, :id, :id_dev, :created_at_dev, :canal, :sku, :cantidad, :precio_unit, :entrega_at, :despacho_at, :estado, :rechazo, :anulacion, :notas, :id_factura_dev
  json.url oc_recibida_url(oc_recibida, format: :json)
end
