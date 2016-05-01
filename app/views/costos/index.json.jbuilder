json.array!(@costos) do |costo|
  json.extract! costo, :id, :SKU, :Descripcion, :Lote, :Unidad, :SKU_Ingrediente, :Ingrediente, :Requerimiento, :Unidad, :Ingrediente, :Precio_Ingrediente
  json.url costo_url(costo, format: :json)
end
