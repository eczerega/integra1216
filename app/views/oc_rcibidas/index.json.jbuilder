json.array!(@oc_rcibidas) do |oc_rcibida|
  json.extract! oc_rcibida, :id, :id_dev, :created_at_dev, :canal, :sku, :cantidad, :precio_unit, :entrega_at, :despacho_at, :estado, :rechazo, :anulacion, :notas, :id_factura_dev
  json.url oc_rcibida_url(oc_rcibida, format: :json)
end
