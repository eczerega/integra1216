json.array!(@factura_ocs) do |factura_oc|
  json.extract! factura_oc, :id, :factura_id, :oc_id, :estado
  json.url factura_oc_url(factura_oc, format: :json)
end
