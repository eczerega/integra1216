json.array!(@produccions) do |produccion|
  json.extract! produccion, :id, :id_dev, :created_at_dev, :fecha_termino
  json.url produccion_url(produccion, format: :json)
end
