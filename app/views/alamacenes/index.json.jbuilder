json.array!(@alamacenes) do |alamacene|
  json.extract! alamacene, :id, :almacenid, :tamano
  json.url alamacene_url(alamacene, format: :json)
end
