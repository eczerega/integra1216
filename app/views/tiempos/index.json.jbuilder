json.array!(@tiempos) do |tiempo|
  json.extract! tiempo, :id, :SKU, :Descripción, :Tipo, :Grupo_Proyecto, :Unidades, :Costo_produccion_unitario, :Lote_Produccion, :Tiempo_Medio_Producción
  json.url tiempo_url(tiempo, format: :json)
end
