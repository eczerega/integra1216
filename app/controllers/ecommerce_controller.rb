require 'json'
require 'net/http'
require 'uri'

class EcommerceController < ApplicationController
  layout false
  def generateHash (contenidoSignature)
    encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','Cfs%agh:i#B8&f6', contenidoSignature)).chomp
    return encoded_string
  end

  skip_before_filter :verify_authenticity_token

  def generateBoleta (proveedor, cliente, total)
    #DESARROLLO
    url = URI("http://mare.ing.puc.cl/facturas/boleta")
    #PRODUCCION
    #url = URI("http://moto.ing.puc.cl/facturas/boleta")

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Put.new(url)
    request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    request["cache-control"] = 'no-cache'
    request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"proveedor\"\r\n\r\n"+proveedor+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"cliente\"\r\n\r\n"+cliente+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"total\"\r\n\r\n"+total+"\r\n-----011000010111000001101001--"

    response = http.request(request)
    puts response.read_body
    return response.read_body
  end

  def generateBoletaApi()
    proveedor = "571262b8a980ba030058ab5a"
    cliente = "123"
    total = "10"
    @boleta = generateBoleta(proveedor,cliente,total)
    @response =  {:boletaGenerada => @boleta}
        respond_to do |format|
          format.html {}
          format.json { render :json => @response }
          format.js
    end
  end

  def contarProductos(almacenId, sku)
      url = URI("http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock?almacenId="+almacenId)
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+ almacenId).to_s
      request["authorization"] = @hashi_get
      request["content-type"] = 'application/json'
      request["cache-control"] = 'no-cache'
      request["postman-token"] = '07cc8b55-6f45-f987-1c5a-0eb4f9648baa'
      response = http.request(request)
      puts response.body
      total = 0
      JSON.parse(response.body).each do |line|
        if sku == line["_id"]
          total += line["total"].to_i
        end
      end
      return total
  end

  def contarTotal(sku)
    #url = URI("http://integracion-2016-prod.herokuapp.com/bodega/almacenes")
    url = URI("http://integracion-2016-prod.herokuapp.com/bodega/almacenes")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET').to_s
    request["authorization"] = @hashi_get
    request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '87c4769c-086d-7a1a-a299-d68b4be2f76a'
    response = http.request(request)
    total = 0
    JSON.parse(response.body).each do |line|
      almacen = line["_id"]
      puts "\nALMACEN\n"
      puts almacen
      puts "\nEND ALMACEN\n"
      total += contarProductos(almacen, sku)
      end
      return total  
  end

  def despachar_borrador(id_boleta, sku, cantidad)
    if cantidad.to_i<contarTotal(sku)
      puts "SE PREPARA DESPACHO"
      #preparar_despacho(@oc_id.to_s, @oc_sku, @oc_cantidad, @oc_precio)
    else
      puts "NO HAY SUFICIENTE STOCK"
    end
  end

  def despachar()
    id_boleta=params["id_boleta"].to_s
    sku=params["sku"].to_s
    cantidad=params["cantidad"].to_s
    despachar_borrador(id_boleta, sku, cantidad)
  end
end


