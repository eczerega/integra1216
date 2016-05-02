json.array!(@sku_stocks) do |sku_stock|
  json.extract! sku_stock, :id, :SKU, :stock
  json.url sku_stock_url(sku_stock, format: :json)
end
