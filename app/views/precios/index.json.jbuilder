json.array!(@precios) do |precio|
  json.extract! precio, :id, :SKU, :Descripción, :Precio_Unitario
  json.url precio_url(precio, format: :json)
end
