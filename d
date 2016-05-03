[1mdiff --git a/API.rb b/API.rb[m
[1mindex 329ff99..4209482 100644[m
[1m--- a/API.rb[m
[1m+++ b/API.rb[m
[36m@@ -16,9 +16,21 @@[m [mdef generateHash (contenidoSignature)[m
     return encoded_string[m
 end[m
 [m
[31m-def getJSONData(url_req)[m
[31m-    @hashi = 'INTEGRACION grupo12:'+generateHash('GET').to_s[m
[31m-    url = URI.parse(url_req)[m
[32m+[m[32mdef getJSONData(url_req, param_string)[m
[32m+[m[32m    @hashi = 'INTEGRACION grupo12:'+generateHash('GET'+param_string).to_s[m
[32m+[m[32m    url = URI.parse("http://mare.ing.puc.cl/banco/"+url_req)[m
[32m+[m[32m    req = Net::HTTP::Get.new(url.to_s)[m
[32m+[m[32m    req['Authorization'] = @hashi[m
[32m+[m[32m    res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m      http.request(req)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    return res.body[m
[32m+[m[32mend[m
[32m+[m
[32m+[m[32mdef getBodegaJSONData(url_req, param_string)[m
[32m+[m[32m    @hashi = 'INTEGRACION grupo12:'+generateHash('GET'+param_string).to_s[m
[32m+[m[32m    url = URI.parse("http://integracion-2016-dev.herokuapp.com/bodega/"+url_req)[m
     req = Net::HTTP::Get.new(url.to_s)[m
     req['Authorization'] = @hashi[m
     res = Net::HTTP.start(url.host, url.port) {|http|[m
[36m@@ -28,20 +40,61 @@[m [mdef getJSONData(url_req)[m
     return res.body[m
 end[m
 [m
[31m-def putJSONData(url_req, params)[m
[31m-    @hashi = 'INTEGRACION grupo12:'+generateHash('PUT').to_s[m
[32m+[m[32mdef getBancoJSONData(url_req)[m
[32m+[m[32m    @hashi = 'INTEGRACION grupo12:'+generateHash('GET').to_s[m
[32m+[m[32m    url = URI.parse("http://mare.ing.puc.cl/banco/"+url_req)[m
[32m+[m[32m    req = Net::HTTP::Get.new(url.to_s)[m
[32m+[m[32m    #req['Authorization'] = @hashi[m
[32m+[m[32m    res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m      http.request(req)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    return res.body[m
[32m+[m[32mend[m
[32m+[m
[32m+[m[32mdef putBodegaJSONData(url_req, params, param_string)[m
[32m+[m[32m    @hashi = 'INTEGRACION grupo12:'+generateHash('PUT'+param_string).to_s[m
     puts @hashi[m
[31m-    url = URI.parse(url_req)[m
[31m-    req = Net::HTTP::Put.new(url.to_s)[m
[32m+[m[41m    [m
[32m+[m[32m    url = URI.parse("http://integracion-2016-dev.herokuapp.com/bodega/"+url_req)[m
[32m+[m[32m    req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})[m
     req['Authorization'] = @hashi[m
[31m-    req['Params'] = params[m
[32m+[m[32m    req.body=params[m
     res = Net::HTTP.start(url.host, url.port) {|http|[m
       http.request(req)[m
     }[m
[31m-    return res.body   [m
[32m+[m
[32m+[m[32m    puts res.code[m
[32m+[m
[32m+[m[32m    if res.code[0]=='4' || res.code[0]=='5'[m
[32m+[m[32m      puts res[m
[32m+[m[32m      return "error"[m
[32m+[m[32m    elsif res.code[0]=='2'[m
[32m+[m[32m      return res.body[m
[32m+[m[32m    else[m
[32m+[m[32m      return "request_error"[m
[32m+[m[32m    end[m
 end[m
 [m
[32m+[m[32mdef putBancoJSONData(url_req, params)[m
[32m+[m[41m  [m
[32m+[m[32m    url = URI.parse("http://mare.ing.puc.cl/banco/"+url_req)[m
[32m+[m[32m    req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})[m
[32m+[m[32m    req.body=params[m
[32m+[m[32m    res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m      http.request(req)[m
[32m+[m[32m    }[m
 [m
[32m+[m[32m    puts res.code[m
[32m+[m[32m    if res.code[0]=='4' || res.code[0]=='5'[m
[32m+[m[32m      puts res[m
[32m+[m[32m      return "error"[m
[32m+[m[32m    elsif res.code[0]=='2'[m
[32m+[m[32m      return res.body[m
[32m+[m[32m    else[m
[32m+[m[32m      return "request_error"[m
[32m+[m[32m    end[m
[32m+[m[32mend[m
 [m
 def ApiBodegaGetAlmacenes(request)[m
   @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+request).to_s[m
[36m@@ -68,52 +121,74 @@[m [mdef getInfoFromJSON(input,field)[m
   return @data[0][m
 end[m
 [m
[31m-def ApiProducirMp(sku, num_batch)[m
[31m-[m
[32m+[m[32mdef producir_mp(sku, num_batch)[m
[32m+[m[32m  sku = params[:sku][m
[32m+[m[32m  num_batch = params[:num_batch][m
   if sku!=7 && sku!=15[m
     puts "Nosotros no producimos ese producto"[m
   else[m
     puts "Vas a producir el sku: "+sku.to_s+" con "+num_batch.to_s+" número de batchs"[m
     costo_unitario=0[m
[32m+[m[32m    cant_sku=0[m
 [m
     if sku==7[m
[31m-      costo_unitario=941[m
[32m+[m[32m      cant_sku=1000[m
[32m+[m[32m      costo_unitario=941*cant_sku[m
     elsif sku==15[m
[31m-      costo_unitario=969[m
[32m+[m[32m      cant_sku=480[m
[32m+[m[32m      costo_unitario=969*cant_sku[m
     end[m
 [m
     costo_prod=costo_unitario*num_batch[m
[32m+[m[32m    cant_prod=num_batch*cant_sku[m
     puts "El costo unitario por batch es "+costo_unitario.to_s+" y el costo total de esta producción es "+costo_prod.to_s[m
 [m
[31m-    @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET').to_s[m
[31m-    @hashi_put = 'INTEGRACION grupo12:'+generateHash('PUT').to_s[m
[31m-    #puts @hashi_get.to_s[m
     url_bodega = "http://integracion-2016-dev.herokuapp.com/bodega/"[m
     url_banco = "http://mare.ing.puc.cl/banco/"[m
 [m
[31m-    @response = getJSONData(url_banco+"cuenta/571262c3a980ba030058ab65")[m
 [m
[32m+[m[32m    @response = getBancoJSONData("cuenta/571262c3a980ba030058ab65")[m
     saldo = getInfoFromJSON(@response,"saldo")[m
[32m+[m[41m    [m
     puts saldo[m
 [m
[31m-    if saldo >= costo_prod[m
[31m-      @response2 = getJSONData(url_bodega+"fabrica/getCuenta")[m
[31m-      puts @response2[m
[31m-[m
[31m-      cuenta_id = getInfoFromJSON(@response2,"cuenta_id");[m
[31m-      puts cuenta_id[m
[31m-[m
[31m-      #puts RestClient.put url_banco+"trx", {:Authorization => @hashi_get, :Params => {"monto":costo_prod,"origen":"571262c3a980ba030058ab65","destino":"cuenta_id"}}[m
[31m-      #response3 = JSON.parse RestClient.put url_banco+"trx", {:Authorization => @hashi_get, :Params => {"monto":costo_prod,"origen":"571262c3a980ba030058ab65","destino":"cuenta_id"}}[m
[31m-    else[m
[31m-      puts "No hay saldo suficiente para producir"[m
[31m-    end [m
[32m+[m[32m    # if saldo >= costo_prod[m
[32m+[m[32m    #   @response2 = getBodegaJSONData("fabrica/getCuenta","")[m
[32m+[m[32m    #   cuenta_id = JSON.parse(@response2)["cuentaId"][m
[32m+[m[32m    #   puts cuenta_id[m
[32m+[m
[32m+[m[32m    #   aux_hash={:monto=>costo_prod, :origen=>"571262c3a980ba030058ab65", :destino=>cuenta_id}[m
[32m+[m[32m    #   jsonbody = JSON.generate(aux_hash)[m
[32m+[m[32m    #   puts jsonbody[m
[32m+[m
[32m+[m[32m    #   #@response3 = putBancoJSONData('trx',jsonbody)[m
[32m+[m[32m    #   #puts @response3[m
[32m+[m[32m    #   if @response3=="error" || @response3=="request_error"[m
[32m+[m[32m    #     puts "TRX error, can't continue"[m
[32m+[m[32m    #   else[m
[32m+[m[32m    #     #trx_id = JSON.parse(@response3)["_id"][m
[32m+[m[32m    #     trx_id = "572778bbc1ff9b0300017d37"[m
[32m+[m[32m    #     puts trx_id[m
[32m+[m
[32m+[m[32m    #     aux_hash2 = {:sku=>sku.to_s, :trxId=>trx_id, :cantidad=>cant_prod}[m
[32m+[m[32m    #     jsonbody2 = JSON.generate(aux_hash2)[m
[32m+[m
[32m+[m[32m    #     @response4 = putBodegaJSONData("fabrica/fabricar",jsonbody2,sku.to_s+cant_prod.to_s+trx_id)[m
[32m+[m[32m    #     puts @response4[m
[32m+[m
[32m+[m[32m    #   end[m
[32m+[m[32m    # else[m
[32m+[m[32m    #   puts "No hay saldo suficiente para producir"[m
[32m+[m[32m    # end[m[41m [m
   end[m
[32m+[m[32mend[m
 [m
[31m-  [m
 [m
[31m-end[m
[32m+[m[32mdef comprar_producto(sku,cantidad)[m
[32m+[m[32m  hola = Tiempo.where(SKU:sku)[m
 [m
[32m+[m[32m  puts hola[m
[32m+[m[32mend[m
 =begin[m
 def stock(sku, cantidad)[m
   data = ApiBodegaGetAlmacenes('')[m
[36m@@ -144,6 +219,8 @@[m [mdef stock(sku, cantidad)[m
 end[m
 =end[m
 #puts ApiBodegaGetAlmacenes('')[m
[31m-puts ApiProducirMp(7,1)[m
[32m+[m[32m#puts ApiProducirMp(7,1)[m
[32m+[m[32m#puts generateHash("PUT914571262c3a980ba030058ab65571262aea980ba030058a5d8")[m
 #puts stock('47',86)[m
 [m
[32m+[m[32mcomprar_producto(1,1)[m
[1mdiff --git a/app/controllers/orders_controller.rb b/app/controllers/orders_controller.rb[m
[1mindex d7c0677..2f07085 100644[m
[1m--- a/app/controllers/orders_controller.rb[m
[1m+++ b/app/controllers/orders_controller.rb[m
[36m@@ -24,6 +24,77 @@[m [mclass OrdersController < ApplicationController[m
 		return res.body		[m
 	end[m
 [m
[32m+[m	[32mdef getStockJson(num_grupo,sku)[m
[32m+[m		[32murl_req = "http://integra"+num_grupo.to_s+".ing.puc.cl/api/consultar/"+sku+".json"[m
[32m+[m
[32m+[m		[32murl = URI.parse(url_req)[m
[32m+[m		[32mreq = Net::HTTP::Get.new(url.to_s)[m
[32m+[m		[32mres = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m		[32m  http.request(req)[m
[32m+[m		[32m}[m
[32m+[m		[32mreturn res.body[m
[32m+[m	[32mend[m
[32m+[m
[32m+[m	[32mdef getEnviarOC(num_grupo,oc_id)[m
[32m+[m		[32murl_req = "http://integra"+num_grupo.to_s+".ing.puc.cl/api/oc/recibir/"+oc_id+".json"[m
[32m+[m
[32m+[m		[32mif[m[41m [m
[32m+[m		[32murl = URI.parse(url_req)[m
[32m+[m		[32mreq = Net::HTTP::Get.new(url.to_s)[m
[32m+[m		[32mres = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m		[32m  http.request(req)[m
[32m+[m		[32m}[m
[32m+[m		[32mreturn res.body[m
[32m+[m	[32mend[m
[32m+[m
[32m+[m	[32mdef putBodegaJSONData(url_req, params, param_string)[m
[32m+[m[32m      @hashi = 'INTEGRACION grupo12:'+generateHash('PUT'+param_string).to_s[m
[32m+[m[32m      puts @hashi[m
[32m+[m[41m      [m
[32m+[m[32m      url = URI.parse("http://mare.ing.puc.cl/oc"+url_req)[m
[32m+[m[32m      req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})[m
[32m+[m[32m      req['Authorization'] = @hashi[m
[32m+[m[32m      req.body=params[m
[32m+[m[32m      res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m        http.request(req)[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      puts res.code[m
[32m+[m
[32m+[m[32m      if res.code[0]=='4' || res.code[0]=='5'[m
[32m+[m[32m        puts res[m
[32m+[m[32m        return "error"[m
[32m+[m[32m      elsif res.code[0]=='2'[m
[32m+[m[32m        return res.body[m
[32m+[m[32m      else[m
[32m+[m[32m        return "request_error"[m
[32m+[m[32m      end[m
[32m+[m[41m  [m	[32mend[m
[32m+[m
[32m+[m[41m  [m	[32mdef putOCJSONData(url_req, params, param_string)[m
[32m+[m[32m      @hashi = 'INTEGRACION grupo12:'+generateHash('PUT'+param_string).to_s[m
[32m+[m[32m      puts @hashi[m
[32m+[m[41m      [m
[32m+[m[32m      url = URI.parse("http://mare.ing.puc.cl/oc"+url_req)[m
[32m+[m[32m      req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})[m
[32m+[m[32m      req['Authorization'] = @hashi[m
[32m+[m[32m      req.body=params[m
[32m+[m[32m      res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m        http.request(req)[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      puts res.code[m
[32m+[m
[32m+[m[32m      if res.code[0]=='4' || res.code[0]=='5'[m
[32m+[m[32m        puts res.body[m
[32m+[m[32m        return "error"[m
[32m+[m[32m      elsif res.code[0]=='2'[m
[32m+[m[32m        return res.body[m
[32m+[m[32m      else[m
[32m+[m[32m        return "request_error"[m
[32m+[m[32m      end[m
[32m+[m[41m  [m	[32mend[m
[32m+[m
 	def index[m
 		@data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/almacenes', 'GET', '')[m
 		@data.each_line do |line|[m
[36m@@ -33,6 +104,41 @@[m [mclass OrdersController < ApplicationController[m
 	  #@response = JSON.parse RestClient.get data_ur_almacenes, {:Authorization => @hashi}[m
 	end[m
 [m
[32m+[m	[32mdef comprar_producto()[m
[32m+[m	[32m  cantidad_ = params[:cantidad].to_s[m
[32m+[m	[32m  sku_ = params[:sku].to_s[m
[32m+[m
[32m+[m	[32m  grupo_proyecto = Tiempo.where(SKU:sku_).take[:Grupo_Proyecto][m
[32m+[m	[32m  precio_producto = Tiempo.where(SKU:sku_).take[:Costo_produccion_unitario][m
[32m+[m	[32m  tiempo_produccion_prod = Tiempo.where(SKU:sku_).take[:Tiempo_Medio_Producción][m
[32m+[m	[32m  puts grupo_proyecto[m
[32m+[m	[32m  puts precio_producto[m
[32m+[m	[32m  puts tiempo_produccion_prod[m
[32m+[m
[32m+[m	[32m  fecha_entrega = (DateTime.now+tiempo_produccion_prod.hours+1.hours).strftime('%Q')[m
[32m+[m	[32m  puts fecha_entrega[m
[32m+[m
[32m+[m	[32m  stock = JSON.parse(getStockJson(grupo_proyecto,sku_))["stock"][m
[32m+[m	[32m  puts stock[m
[32m+[m
[32m+[m	[32m  #cambiar < !!![m
[32m+[m	[32m  if stock.to_i<=cantidad_.to_i[m
[32m+[m	[41m  [m	[32moc_generada = {:canal=>"b2b",:cantidad=>cantidad_,:sku=>sku_,:cliente=>"12",:proveedor=>grupo_proyecto,:precioUnitario=>precio_producto,:fechaEntrega=>fecha_entrega.to_i,:notas=>"nada"}[m
[32m+[m	[41m  [m	[32mjsonbody = JSON.generate(oc_generada)[m
[32m+[m	[41m  [m	[32mputs jsonbody[m
[32m+[m
[32m+[m	[41m  [m	[32mresponse = putOCJSONData("/crear",jsonbody,"b2b"+cantidad_+sku_+"12")[m
[32m+[m	[41m  [m	[32moc_id = JSON.parse(response)["_id"][m
[32m+[m	[41m  [m	[32mputs oc_id[m
[32m+[m
[32m+[m	[32m  else[m
[32m+[m	[41m  [m	[32mputs "No hay stock suficiente de ese producto para comprar"[m
[32m+[m	[32m  end[m[41m	  [m
[32m+[m
[32m+[m	[32m  respond_to do |format|[m
[32m+[m[32m        format.json {  }[m
[32m+[m[32m      end[m
[32m+[m	[32mend[m
 [m
 end[m
 #rails g scaffold oc_recibidas id_dev:string created_at_dev:date canal:string sku:string cantidad:integer precio_unit:integer entrega_at:date despacho_at:date estado:string rechazo:string anulacion:string notas:string id_factura_dev:string[m
\ No newline at end of file[m
[1mdiff --git a/app/controllers/produccions_controller.rb b/app/controllers/produccions_controller.rb[m
[1mindex 5da3a85..f469aeb 100644[m
[1m--- a/app/controllers/produccions_controller.rb[m
[1m+++ b/app/controllers/produccions_controller.rb[m
[36m@@ -1,16 +1,161 @@[m
 [m
 url_bodega="http://integracion-2016-dev.herokuapp.com/bodega"[m
 [m
[31m-#permite generar el hash para las distintas autorizaciones, lo retorna[m
[31m-def generateHash (contenidoSignature)[m
[31m-  return Base64.encode64((HMAC::SHA1.new('akVf0btGVOwkhvI') << contenidoSignature).digest).strip[m
[31m-end[m
[32m+[m
 [m
 class ProduccionsController < ApplicationController[m
   before_action :set_produccion, only: [:show, :edit, :update, :destroy][m
     layout false[m
 [m
[32m+[m[32m          #permite generar el hash para las distintas autorizaciones, lo retorna[m
[32m+[m[32m  def generateHash (contenidoSignature)[m
[32m+[m[32m      encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp[m
[32m+[m[32m      return encoded_string[m
[32m+[m[32m  end[m
[32m+[m
[32m+[m[32m  def getBodegaJSONData(url_req, param_string)[m
[32m+[m[32m      @hashi = 'INTEGRACION grupo12:'+generateHash('GET'+param_string).to_s[m
[32m+[m[32m      url = URI.parse("http://integracion-2016-dev.herokuapp.com/bodega/"+url_req)[m
[32m+[m[32m      req = Net::HTTP::Get.new(url.to_s)[m
[32m+[m[32m      req['Authorization'] = @hashi[m
[32m+[m[32m      res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m        http.request(req)[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      return res.body[m
[32m+[m[32m  end[m
[32m+[m
[32m+[m[32m  def getBancoJSONData(url_req)[m
[32m+[m[32m      @hashi = 'INTEGRACION grupo12:'+generateHash('GET').to_s[m
[32m+[m[32m      url = URI.parse("http://mare.ing.puc.cl/banco/"+url_req)[m
[32m+[m[32m      req = Net::HTTP::Get.new(url.to_s)[m
[32m+[m[32m      #req['Authorization'] = @hashi[m
[32m+[m[32m      res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m        http.request(req)[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      return res.body[m
[32m+[m[32m  end[m
[32m+[m
[32m+[m[32m  def putBodegaJSONData(url_req, params, param_string)[m
[32m+[m[32m      @hashi = 'INTEGRACION grupo12:'+generateHash('PUT'+param_string).to_s[m
[32m+[m[32m      puts @hashi[m
[32m+[m[41m      [m
[32m+[m[32m      url = URI.parse("http://integracion-2016-dev.herokuapp.com/bodega/"+url_req)[m
[32m+[m[32m      req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})[m
[32m+[m[32m      req['Authorization'] = @hashi[m
[32m+[m[32m      req.body=params[m
[32m+[m[32m      res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m        http.request(req)[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      puts res.code[m
[32m+[m
[32m+[m[32m      if res.code[0]=='4' || res.code[0]=='5'[m
[32m+[m[32m        puts res[m
[32m+[m[32m        return "error"[m
[32m+[m[32m      elsif res.code[0]=='2'[m
[32m+[m[32m        return res.body[m
[32m+[m[32m      else[m
[32m+[m[32m        return "request_error"[m
[32m+[m[32m      end[m
[32m+[m[32m  end[m
[32m+[m
[32m+[m[32m  def putBancoJSONData(url_req, params)[m
[32m+[m[41m    [m
[32m+[m[32m      url = URI.parse("http://mare.ing.puc.cl/banco/"+url_req)[m
[32m+[m[32m      req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})[m
[32m+[m[32m      req.body=params[m
[32m+[m[32m      res = Net::HTTP.start(url.host, url.port) {|http|[m
[32m+[m[32m        http.request(req)[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      puts res.code[m
[32m+[m[32m      if res.code[0]=='4' || res.code[0]=='5'[m
[32m+[m[32m        puts res[m
[32m+[m[32m        return "error"[m
[32m+[m[32m      elsif res.code[0]=='2'[m
[32m+[m[32m        return res.body[m
[32m+[m[32m      else[m
[32m+[m[32m        return "request_error"[m
[32m+[m[32m      end[m
[32m+[m[32m  end[m
[32m+[m
[32m+[m[32m  def getInfoFromJSON(input,field)[m
[32m+[m[32m    @data=Array.new[m
[32m+[m[32m      JSON.parse(input).each do |data_value|[m
[32m+[m[32m        @data.push(data_value[field])[m
[32m+[m[32m      end[m
[32m+[m
[32m+[m[32m    return @data[0][m
[32m+[m[32m  end[m
[32m+[m
[32m+[m[32m  def ApiProducirMp()[m
[32m+[m[32m    sku = params[:sku].to_i[m
[32m+[m[32m    num_batch = params[:num_batch].to_i[m
[32m+[m[41m    [m
[32m+[m
[32m+[m[32m    if sku!=7 && sku!=15[m
[32m+[m[32m      puts "Nosotros no producimos ese producto"[m
[32m+[m[32m    else[m
[32m+[m[32m      puts "Vas a producir el sku: "+sku.to_s+" con "+num_batch.to_s+" número de batchs"[m
[32m+[m[32m      costo_unitario=0[m
[32m+[m[32m      cant_sku=0[m
[32m+[m
[32m+[m[32m      if sku==7[m
[32m+[m[32m        cant_sku=1000[m
[32m+[m[32m        costo_unitario=941*cant_sku[m
[32m+[m[32m      elsif sku==15[m
[32m+[m[32m        cant_sku=480[m
[32m+[m[32m        costo_unitario=969*cant_sku[m
[32m+[m[32m      end[m
[32m+[m
[32m+[m[32m      costo_prod=costo_unitario*num_batch[m
[32m+[m[32m      cant_prod=num_batch*cant_sku[m
[32m+[m[32m      puts "El costo unitario por batch es "+costo_unitario.to_s+" y el costo total de esta producción es "+costo_prod.to_s[m
[32m+[m
[32m+[m[32m      url_bodega = "http://integracion-2016-dev.herokuapp.com/bodega/"[m
[32m+[m[32m      url_banco = "http://mare.ing.puc.cl/banco/"[m
[32m+[m
[32m+[m
[32m+[m[32m      @response = getBancoJSONData("cuenta/571262c3a980ba030058ab65")[m
[32m+[m[32m      saldo = getInfoFromJSON(@response,"saldo")[m
[32m+[m[41m      [m
[32m+[m[32m      puts saldo[m
[32m+[m
[32m+[m[32m      if saldo >= costo_prod[m
[32m+[m[32m        @response2 = getBodegaJSONData("fabrica/getCuenta","")[m
[32m+[m[32m        cuenta_id = JSON.parse(@response2)["cuentaId"][m
[32m+[m[32m        puts cuenta_id[m
[32m+[m
[32m+[m[32m        aux_hash={:monto=>costo_prod, :origen=>"571262c3a980ba030058ab65", :destino=>cuenta_id}[m
[32m+[m[32m        jsonbody = JSON.generate(aux_hash)[m
[32m+[m[32m        puts jsonbody[m
[32m+[m
[32m+[m[32m        @response3 = putBancoJSONData('trx',jsonbody)[m
[32m+[m[32m        puts @response3[m
[32m+[m[32m        if @response3=="error" || @response3=="request_error"[m
[32m+[m[32m          puts "TRX error, can't continue"[m
[32m+[m[32m        else[m
[32m+[m[32m          trx_id = JSON.parse(@response3)["_id"][m
[32m+[m[32m          puts trx_id[m
 [m
[32m+[m[32m          aux_hash2 = {:sku=>sku.to_s, :trxId=>trx_id, :cantidad=>cant_prod}[m
[32m+[m[32m          jsonbody2 = JSON.generate(aux_hash2)[m
[32m+[m
[32m+[m[32m          @response4 = putBodegaJSONData("fabrica/fabricar",jsonbody2,sku.to_s+cant_prod.to_s+trx_id)[m
[32m+[m[32m          puts @response4[m
[32m+[m
[32m+[m[32m        end[m
[32m+[m[32m      else[m
[32m+[m[32m        puts "No hay saldo suficiente para producir"[m
[32m+[m[32m      end[m[41m [m
[32m+[m
[32m+[m[32m      respond_to do |format|[m
[32m+[m[32m        format.json {  }[m
[32m+[m[32m      end[m
[32m+[m[32m    end[m
[32m+[m[32m  end[m
   # GET /produccions[m
   # GET /produccions.json[m
   def index[m
[36m@@ -87,3 +232,6 @@[m [mclass ProduccionsController < ApplicationController[m
       params.require(:produccion).permit(:id_dev, :created_at_dev, :fecha_termino)[m
     end[m
 end[m
[41m+[m
[41m+[m
[41m+[m
[1mdiff --git a/config/routes.rb b/config/routes.rb[m
[1mindex d725f13..2a9ea2d 100644[m
[1m--- a/config/routes.rb[m
[1m+++ b/config/routes.rb[m
[36m@@ -19,8 +19,11 @@[m [mRails.application.routes.draw do[m
   get 'documentation' => 'documentation#index'[m
   get 'api/consultar/:sku' => 'api#got_stock'[m
   put 'oc/crear'=> 'oc_recibidas#crear_oc_api'[m
[31m-  post 'api/oc/recibir/:idoc' => 'api#gestionar_oc'[m
[32m+[m[32m  get 'api/oc/recibir/:idoc' => 'api#gestionar_oc'[m
 [m
[32m+[m
[32m+[m[32m  get 'api/test_felipe' => 'produccions#ApiProducirMp'[m
[32m+[m[32m  get 'api/test_felipe2' => 'orders#comprar_producto'[m
   # You can have the root of your site routed with "root"[m
   # root 'welcome#index'[m
 [m
[1mdiff --git a/db/migrate/20160501230408_create_tiempos.rb b/db/migrate/20160501230408_create_tiempos.rb[m
[1mindex b1febb4..c0400c3 100644[m
[1m--- a/db/migrate/20160501230408_create_tiempos.rb[m
[1m+++ b/db/migrate/20160501230408_create_tiempos.rb[m
[36m@@ -8,7 +8,7 @@[m [mclass CreateTiempos < ActiveRecord::Migration[m
       t.string :Unidades[m
       t.integer :Costo_produccion_unitario[m
       t.integer :Lote_Produccion[m
[31m-      t.integer :Tiempo_Medio_Producción[m
[32m+[m[32m      t.float :Tiempo_Medio_Producción[m
 [m
       t.timestamps null: false[m
     end[m
[1mdiff --git a/db/schema.rb b/db/schema.rb[m
[1mindex ff8dfdb..83508f5 100644[m
[1m--- a/db/schema.rb[m
[1m+++ b/db/schema.rb[m
[36m@@ -106,7 +106,7 @@[m [mActiveRecord::Schema.define(version: 20160502171228) do[m
     t.string   "Unidades"[m
     t.integer  "Costo_produccion_unitario"[m
     t.integer  "Lote_Produccion"[m
[31m-    t.integer  "Tiempo_Medio_Producción"[m
[32m+[m[32m    t.float    "Tiempo_Medio_Producción"[m
     t.datetime "created_at",                null: false[m
     t.datetime "updated_at",                null: false[m
   end[m
[1mdiff --git a/db/seeds.rb b/db/seeds.rb[m
[1mindex 2cbff96..8381e29 100644[m
[1m--- a/db/seeds.rb[m
[1m+++ b/db/seeds.rb[m
[36m@@ -66,10 +66,8 @@[m [mFile.open("./init/tiempos.csv", "r") do |f|[m
 				 Unidades: contenido[4].to_s,[m
 				 Costo_produccion_unitario: contenido[5].to_i,[m
 				 Lote_Produccion: contenido[6].to_i,[m
[31m-				 Tiempo_Medio_Producción: contenido[7].to_i[m
[32m+[m				[32m Tiempo_Medio_Producción: contenido[7].to_f[m
 			)[m
[31m-[m
[31m-[m
 	end[m
 end[m
 [m
[1mdiff --git a/init/tiempos.csv b/init/tiempos.csv[m
[1mindex 321ffa3..14be792 100644[m
[1m--- a/init/tiempos.csv[m
[1m+++ b/init/tiempos.csv[m
[36m@@ -1,5 +1,56 @@[m
[31m-7;Leche;Materia prima;12;Lts; 941 ; 1.000 ;4,248[m
[31m-15;Avena;Materia prima;12;Kg; 969 ; 480 ;3,965[m
[31m-30;Tela de Algod�n ;Producto procesado;12;Mts; 1.698 ; 500 ;3,865[m
[31m-34;Cerveza ;Producto procesado;12;Lts; 1.294 ; 700 ;1,505[m
[31m-51;Pan Hallulla;Producto procesado;12;Kg; 2.153 ; 600 ;1,658[m
\ No newline at end of file[m
[32m+[m[32m1;Pollo;Materia prima;7;Kg; 892 ; 300 ;2.041[m[41m[m
[32m+[m[32m2;Huevo;Materia prima;2;Un; 513 ; 150 ;3.736[m[41m[m
[32m+[m[32m3;Maiz;Materia prima;10;Kg; 1.468 ; 30 ;3.532[m[41m[m
[32m+[m[32m4;Aceite de Maravilla;Producto procesado;11;Lts; 863 ; 200 ;3.026[m[41m[m
[32m+[m[32m5;Yogur ;Producto procesado;11;Lts; 2.197 ; 600 ;3.526[m[41m[m
[32m+[m[32m6;Crema;Producto procesado;3;Lts; 2.402 ; 30 ;0.979[m[41m[m
[32m+[m[32m7;Leche;Materia prima;12;Lts; 941 ; 1.000 ;4.248[m[41m[m
[32m+[m[32m8;Trigo;Materia prima;3;Kg; 1.313 ; 100 ;0.784[m[41m[m
[32m+[m[32m9;Carne;Materia prima;10;Kg; 1.397 ; 620 ;4.279[m[41m[m
[32m+[m[32m10;Pan Marraqueta;Producto procesado;7;Kg; 2.572 ; 900 ;3.677[m[41m[m
[32m+[m[32m11;Margarina ;Producto procesado;4;Kg; 1.839 ; 900 ;4.118[m[41m[m
[32m+[m[32m12;Cereal Avena ;Producto procesado;2;Kg; 2.581 ; 400 ;3.056[m[41m[m
[32m+[m[32m13;Arroz;Materia prima;6;Kg; 1.286 ; 1.000 ;2.890[m[41m[m
[32m+[m[32m14;Cebada;Materia prima;3;Kg; 696 ; 1.750 ;1.355[m[41m[m
[32m+[m[32m15;Avena;Materia prima;12;Kg; 969 ; 480 ;3.965[m[41m[m
[32m+[m[32m16;Pasta de Trigo ;Producto procesado;4;Kg; 2.292 ; 1.000 ;2.992[m[41m[m
[32m+[m[32m17;Cereal Arroz ;Producto procesado;6;Kg; 2.184 ; 1.000 ;2.052[m[41m[m
[32m+[m[32m18;Pastel ;Producto procesado;8;Un; 2.140 ; 200 ;0.941[m[41m[m
[32m+[m[32m19;Semola;Materia prima;1;Kg; 1.428 ; 1.420 ;4.033[m[41m[m
[32m+[m[32m20;Cacao;Materia prima;9;Kg; 1.280 ; 60 ;4.101[m[41m[m
[32m+[m[32m21;Algodon;Materia prima;2;Kg; 1.272 ; 100 ;1.157[m[41m[m
[32m+[m[32m22;Mantequilla ;Producto procesado;11;Kg; 1.891 ; 400 ;1.951[m[41m[m
[32m+[m[32m23;Harina;Producto procesado;7;Kg; 1.534 ; 300 ;3.950[m[41m[m
[32m+[m[32m24;Tela de Seda ;Producto procesado;8;Mts; 1.442 ; 400 ;0.695[m[41m[m
[32m+[m[32m25;Azucar;Materia prima;6;Kg; 782 ; 560 ;1.515[m[41m[m
[32m+[m[32m26;Sal;Materia prima;8;Kg; 753 ; 144 ;0.784[m[41m[m
[32m+[m[32m27;Levadura;Materia prima;1;Kg; 1.084 ; 620 ;2.717[m[41m[m
[32m+[m[32m28;Tela de Lino ;Producto procesado;2;Mts; 1.138 ; 500 ;3.754[m[41m[m
[32m+[m[32m29;Tela de Lana ;Producto procesado;10;Mts; 1.868 ; 400 ;1.961[m[41m[m
[32m+[m[32m30;Tela de Algodon ;Producto procesado;12;Mts; 1.698 ; 500 ;3.865[m[41m[m
[32m+[m[32m31;Lana;Materia prima;3;Mts; 1.434 ; 960 ;3.449[m[41m[m
[32m+[m[32m32;Cuero;Materia prima;2;Un; 996 ; 230 ;2.834[m[41m[m
[32m+[m[32m33;Seda;Materia prima;5;Kg; 834 ; 90 ;0.711[m[41m[m
[32m+[m[32m34;Cerveza ;Producto procesado;12;Lts; 1.294 ; 700 ;1.505[m[41m[m
[32m+[m[32m35;Tequila ;Producto procesado;10;Lts; 1.435 ; 500 ;1.160[m[41m[m
[32m+[m[32m36;Papel ;Producto procesado;11;Mts; 1.786 ; 100 ;3.918[m[41m[m
[32m+[m[32m37;Lino;Materia prima;8;Mts; 764 ; 1.200 ;2.797[m[41m[m
[32m+[m[32m38;Semillas Maravilla;Materia prima;4;Kg; 1.201 ; 30 ;1.805[m[41m[m
[32m+[m[32m39;Uva;Materia prima;7;Kg; 889 ; 250 ;3.753[m[41m[m
[32m+[m[32m40;Queso ;Producto procesado;1;Kg; 2.324 ; 900 ;3.589[m[41m[m
[32m+[m[32m41;Suero de Leche;Producto procesado;10;Lts; 1.407 ; 200 ;3.983[m[41m[m
[32m+[m[32m42;Cereal Maiz;Producto procesado;5;Kg; 1.949 ; 200 ;1.459[m[41m[m
[32m+[m[32m43;Madera;Materia prima;11;Mts3; 1.197 ; 1.000 ;1.270[m[41m[m
[32m+[m[32m44;Agave;Materia prima;4;Kg; 1.091 ; 50 ;2.560[m[41m[m
[32m+[m[32m45;Celulosa;Materia prima;1;Kg; 1.500 ; 800 ;0.759[m[41m[m
[32m+[m[32m46;Chocolate;Producto procesado;9;Kg; 2.372 ; 800 ;1.205[m[41m[m
[32m+[m[32m47;Vino ;Producto procesado;1;Lts; 1.921 ; 1.000 ;0.677[m[41m[m
[32m+[m[32m48;Pasta de Semola ;Producto procesado;9;Kg; 1.652 ; 500 ;2.470[m[41m[m
[32m+[m[32m49;Leche Descremada;Producto procesado;3;Lts; 1.459 ; 200 ;4.281[m[41m[m
[32m+[m[32m50;Arroz con Leche;Producto procesado;5;Kg; 1.940 ; 350 ;4.058[m[41m[m
[32m+[m[32m51;Pan Hallulla;Producto procesado;12;Kg; 2.153 ; 600 ;1.658[m[41m[m
[32m+[m[32m52;Harina Integral;Materia prima;5;Kg; 1.466 ; 890 ;2.130[m[41m[m
[32m+[m[32m53;Pan Integral;Producto procesado;6;Kg; 2.632 ; 620 ;3.890[m[41m[m
[32m+[m[32m54;Hamburguesas;Producto procesado;10;Kg; 2.190 ; 1.800 ;4.012[m[41m[m
[32m+[m[32m55;Galletas Integrales;Producto procesado;3;Kg; 2.284 ; 950 ;3.955[m[41m[m
[32m+[m[32m56;Hamburguesas de Pollo;Producto procesado;9;Kg; 2.271 ; 620 ;2.010[m[41m[m
