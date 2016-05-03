require 'rubygems'
require 'rest-client'
require 'base64'
require 'cgi'
require 'openssl'
require 'hmac-sha1'
require 'json'
require 'net/http'
#require 'digest/hmac'



#permite generar el hash para las distintas autorizaciones, lo retorna
def generateHash (contenidoSignature)
    encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
    return encoded_string
end

def getJSONData(url_req)
    @hashi = 'INTEGRACION grupo12:'+generateHash('GET').to_s
    url = URI.parse(url_req)
    req = Net::HTTP::Get.new(url.to_s)
    req['Authorization'] = @hashi
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    return res.body
end

def putJSONData(url_req, params)
    @hashi = 'INTEGRACION grupo12:'+generateHash('PUT').to_s
    puts @hashi
    url = URI.parse(url_req)
    req = Net::HTTP::Put.new(url.to_s)
    req['Authorization'] = @hashi
    req['Params'] = params
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    return res.body   
end

def generar_factura(id_oc)
      url = URI("http://mare.ing.puc.cl/facturas/")
    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Put.new(url)
    request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    request["authorization"] = 'INTEGRACION grupo12:'+generateHash('PUT'+id_oc).to_s
    request["cache-control"] = 'no-cache'
    request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"oc\"\r\n\r\n"+id_oc+"\r\n-----011000010111000001101001--"

    @response = http.request(request)
    @response_json = JSON.parse(@response.body)
    @factura_id = @response_json["_id"]
    return @factura_id
  end

  def aceptar_orden(id_oc)
    url = URI("http://mare.ing.puc.cl/oc/recepcionar/"+id_oc)
  http = Net::HTTP.new(url.host, url.port)

  request = Net::HTTP::Post.new(url)
  request["authorization"] = 'INTEGRACION grupo12:'+generateHash('POST'+id_oc).to_s
  request["cache-control"] = 'no-cache'

  @response = http.request(request)
  @response_json = JSON.parse(@response.body)
  return @response_json
  end

  def enviar_factura(id_factura, id_cliente)
    @response = JSON.parse RestClient.post "http://integra"+id_cliente+".ing.puc.cl/api/facturas/recibir/.:"+id_factura
    return @response
  end

  def mover_a_bodega(id_producto, id_almacen)
      url = URI("http://integracion-2016-dev.herokuapp.com/bodega/moveStock")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    @hashi_get = 'INTEGRACION grupo12:'+generateHash('POST'+ id_producto + id_almacen).to_s
    request["authorization"] = @hashi_get
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request["postman-token"] = 'afdedc9a-5265-3c5b-971d-16c402393539'
    request.body = "{\n    \"almacenId\": \""+ id_almacen +"\",\n    \"productoId\": \""+id_producto+"\"\n}"
    response = http.request(request)
    #puts response.read_body
  end

  def contarProductos(almacenId, sku)
      url = URI("http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock?almacenId="+almacenId)
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

  def iterarProductos(almacenId, sku, qty)
    @almacen_despacho = '571262aba980ba030058a5c7'
    url = URI("http://integracion-2016-dev.herokuapp.com/bodega/stock?almacenId=" + almacenId + "&sku=" + sku + "&limit=199" )
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+ almacenId + sku).to_s
    request["authorization"] = @hashi_get 
    request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '2d38d414-b654-7ea2-d7f2-e1379efa0526'
    response = http.request(request)
    JSON.parse(response.body).each do |line|
      @producto_a_mover = line["_id"].to_s
      mover_a_bodega(@producto_a_mover, @almacen_despacho)
      qty -= 1
      if qty == 0
        return qty
      end
    end

    return qty
  end

  def despachar(id_oc, sku, cantidad)

      #571262aba980ba030058a5c7 despacho
      #571262aba980ba030058a5c6 recepcion
      #571262aba980ba030058a5d7 pulmon
      #571262aba980ba030058a5c8 otra
      #571262aba980ba030058a5d6 otra
      @mis_almacenes = ["571262aba980ba030058a5c7", "571262aba980ba030058a5d7", "571262aba980ba030058a5c6", "571262aba980ba030058a5c8", "571262aba980ba030058a5d6"]

  end

  def preparar_despacho(id_oc, sku, cantidad)

      #571262aba980ba030058a5c7 despacho
      #571262aba980ba030058a5c6 recepcion
      #571262aba980ba030058a5d7 pulmon
      #571262aba980ba030058a5c8 otra
      #571262aba980ba030058a5d6 otra
      almacen_despacho = '571262aba980ba030058a5c7'
      current_stock = contarProductos(almacen_despacho, sku)
      if cantidad <= current_stock
        puts "listos para despachar"
        ###despachar()
      else
        puts "debemos mover cosas"
        @mis_almacenes = ["571262aba980ba030058a5d7", "571262aba980ba030058a5c6", "571262aba980ba030058a5c8", "571262aba980ba030058a5d6"]
        faltante = cantidad - current_stock
        ###REVISO SI EN TODOS MIS ALMACENES TENGO STOCK
        @mis_almacenes.each do |almacen|
          faltante += contarProductos(almacen, sku)
          if cantidad <= faltante + current_stock
            break
          end
        end

        ###UNA VEZ CONFIRMADO MI STOCK, MUEVO LOS PRODUCTOS PARA EL DESPACHO
        if cantidad <= faltante + current_stock
          @mis_almacenes.each do |almacen|
            faltante = iterarProductos(almacen, sku, faltante)
            puts 'faltan ' + faltante.to_s  
            if faltante == 0
              break
            end
          end
          puts "despachamos!"
          ###despachar()
        else
          ###NO SE PUEDE DESPACHAR
        end
      end 
  end

def restaurar
  iterarProductos("571262aba980ba030058a5c7",'7',45)
end

#puts aceptar_orden("57265e0f006ba10300bc4390")
#puts 'INTEGRACION grupo12:'+generateHash('GET'+'57281872c1ff9b030001a2e4').to_s
#puts stock('47',86)
puts preparar_despacho('5728488cc1ff9b030001a5c3', '7', 105)
#puts restaurar