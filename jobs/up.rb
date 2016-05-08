
require 'rest-client'
require 'base64'
require 'cgi'
require 'openssl'
require 'hmac-sha1'
require 'json'
require 'net/http'

  def generateHash (contenidoSignature)
    encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','Cfs%agh:i#B8&f6', contenidoSignature)).chomp
    return encoded_string
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
    puts almacen
    total += contarProductos(almacen, sku)
    end
    return total  
end


def moverProductos(id_oc, almacenId, destinoId, sku, cantidad, faltante, precio)
    @almacen_despacho = '571262aba980ba030058a5c7'
    url = URI("http://integracion-2016-prod.herokuapp.com/bodega/stock?almacenId=" + almacenId + "&sku=" + sku + "&limit=199" )
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
        puts @producto_a_mover
        if almacenId != @almacen_despacho
          puts "moviendo a despacho..."
          mover_a_bodega(@producto_a_mover, @almacen_despacho)
        end
        puts "despachando desde " + almacenId + " hacia " + destinoId + "..."
        despachar(id_oc, sku, cantidad, @producto_a_mover, destinoId, precio)
        faltante -= 1
        if faltante == 0
            return faltante
        end
      end
    return faltante
end

def mover_a_bodega(id_producto, id_almacen)
    url = URI("http://integracion-2016-prod.herokuapp.com/bodega/moveStock")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    @hashi_get = 'INTEGRACION grupo12:'+generateHash('POST'+ id_producto + id_almacen).to_s
    request["authorization"] = @hashi_get
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request["postman-token"] = 'afdedc9a-5265-3c5b-971d-16c402393539'
    request.body = "{\n    \"almacenId\": \""+ id_almacen +"\",\n    \"productoId\": \""+id_producto+"\"\n}"
    response = http.request(request)
end

def calcular_espacio
  espacio_libre = Hash.new
  url = URI("http://integracion-2016-prod.herokuapp.com/bodega/almacenes")
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Get.new(url)
  @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET').to_s
  request["authorization"] = @hashi_get
  request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
  request["cache-control"] = 'no-cache'
  request["postman-token"] = '87c4769c-086d-7a1a-a299-d68b4be2f76a'
  response = http.request(request)
  JSON.parse(response.body).each do |line|
    almacen = line["_id"]
    if almacen != '572aad42bdb6d403005fb742' && almacen!= '572aad42bdb6d403005fb69f'
      usado = line["usedSpace"]
      puts usado
          total = line["totalSpace"]
          espacio_libre[almacen] = total - usado 
    end
    end
    return espacio_libre
end

###MUEVE qty PRODUCTOS DE TIPO sku almacenOrigen a almacenDestinto
def traspaso_interno(almacenOrigen, almacenDestino, sku, qty)
      url = URI("http://integracion-2016-prod.herokuapp.com/bodega/stock?almacenId=" + almacenOrigen + "&sku=" + sku + "&limit=199" )
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+ almacenOrigen + sku).to_s
      request["authorization"] = @hashi_get 
      request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
      request["cache-control"] = 'no-cache'
      request["postman-token"] = '2d38d414-b654-7ea2-d7f2-e1379efa0526'
      response = http.request(request)
      count = 0
      JSON.parse(response.body).each do |line|
        @producto_a_mover = line["_id"].to_s
        puts @producto_a_mover
        puts "moviendo a otra bodega"
        mover_a_bodega(@producto_a_mover, almacenDestino)  
        puts "despachando..."
        count += 1
        if count == qty
          break
        end
      end
end

def siguiente_almacen(almacenId)
  if almacenId == '572aad42bdb6d403005fb6a1'
    return '572aad42bdb6d403005fb741'
  elsif almacenId == '572aad42bdb6d403005fb741'
    return '572aad42bdb6d403005fb6a0'
  else
    return -1 
  end
end

def liberar_bodega_recepcion
  recepcion = '572aad42bdb6d403005fb69f' #ALMACEN DE RECEPCION
  espacio_libre = calcular_espacio ###Hash de espacio disponible
  almacen = '572aad42bdb6d403005fb6a1' #EMPIEZO CON UN ALMACEN QUE NO ES DESPACHO NI PULMON
  for i in 1..56
    sku = i.to_s
    stock_a_mover = contarProductos(recepcion, sku)
    while stock_a_mover > 0
      #puts stock_a_mover
      if stock_a_mover <= espacio_libre[almacen]
        traspaso_interno(recepcion, almacen, sku, stock_a_mover)
        espacio_libre[almacen] -= stock_a_mover
        stock_a_mover = 0
      else
        traspaso_interno(recepcion, almacen, sku, espacio_libre[almacen])
        stock_a_mover -= espacio_libre[almacen]
        espacio_libre[almacen] = 0
        almacen = siguiente_almacen(almacen)
      end
      if almacen == -1
        break
      end
    end
    if almacen == -1
      return 'No se puede mover más stock'
    end
  end
  return 'todos los productos fueron movidos'
end

def crear_trx(monto, origenId, destinoId)
  dinero = monto.to_s
  url = URI("http://mare.ing.puc.cl/banco/trx")
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Put.new(url)
  request["content-type"] = 'application/json'
  request["cache-control"] = 'no-cache'
  request["postman-token"] = 'a6719103-e787-baf6-90db-0618b6f3da85'
  request.body = "{\n    \"monto\": \""+ dinero +"\",\n    \"origen\": \""+ origenId +"\",\n    \"destino\": \""+ destinoId +"\"\n}"
  response = http.request(request)
  puts response.read_body
    
end

def rechazar_factura(facturaId, motivo)
  url = URI("http://mare.ing.puc.cl/facturas/reject")
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Post.new(url)
  request["content-type"] = 'application/json'
  request["cache-control"] = 'no-cache'
  request["postman-token"] = 'a6719103-e787-baf6-90db-0618b6f3da85'
  request.body = "{\n    \"id\": \""+ facturaId +"\",\n    \"motivo\": \""+ motivo +"\",\n}"
  response = http.request(request)
  puts response.read_body
end
#572aad42bdb6d403005fb69f recepcion
#572aad42bdb6d403005fb6a0 despacho
#572aad42bdb6d403005fb6a1 otra
#572aad42bdb6d403005fb741 otra
#572aad42bdb6d403005fb742 pulmon
#puts 'INTEGRACION grupo12:'+generateHash('GET').to_s
#puts crear_trx(1, '571262c3a980ba030058ab65', '571262c3a980ba030058ab60')
#puts contarTotal('15')
#traspaso_interno('572aad42bdb6d403005fb6a1', '572aad42bdb6d403005fb69f', '15', 10)
#puts traspaso_interno('572aad42bdb6d403005fb6a1', '572aad42bdb6d403005fb69f', sku, qty)
puts liberar_bodega_recepcion
def avisar_despacho(almacenId)
    grupo = InfoGrupo.find_by(id_almacen: almacenId).num_grupo
    url = URI("http://integra"+grupo+".ing.puc.cl/api/despachos/recibir/"+id_factura)
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    request["cache-control"] = 'no-cache'
    @response = http.request(request)
    @response_json = JSON.parse(@response.body)
    puts @response_json
  end
def recibir_despacho
    @id_fac = params[:idfactura]
    @id_oc = FacturaOc.find_by(factura_id: @id_fac).oc_id
    @sku = OcRecibida.find_by(id_dev: @id_oc)
    actual = SkuStock.find_by(SKU: @sku)
    real = contarTotal2(@sku)
    if actual == real
      @response =  {:validado => 'false'}
        respond_to do |format|
          format.html {}
          format.json { render :json => @response.to_json }
          format.js
        end
    else
      SkuStock.find_by(SKU: @sku).stock = real
      @response =  {:validado => 'true'}
        respond_to do |format|
          format.html {}
          format.json { render :json => @response.to_json }
          format.js
        end
    end 
  end