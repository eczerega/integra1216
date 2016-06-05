module Spree
  class OrdersController < Spree::StoreController
    before_action :check_authorization
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/products', 'spree/orders'

    respond_to :html

    before_action :assign_order_with_lock, only: :update
    skip_before_action :verify_authenticity_token, only: [:populate]

  def generateHash (contenidoSignature)
    #PRODUCCION
    #encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','Cfs%agh:i#B8&f6', contenidoSignature)).chomp
    #DESARROLLO
    encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
    return encoded_string
  end



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
    @oc_array = JSON.parse(response.body)
    @oc_json = JSON.parse(@oc_array.to_json)
    puts 'por la putaaaaa;  ' + @oc_json["_id"].to_s
    return @oc_json["_id"].to_s
  end

  def contarProductos(almacenId, sku)
      #PRODUCCION
      #url = URI("http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock?almacenId="+almacenId)
      #DESARROLLO
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

  def contarTotal(sku)
    #PRODUCCION
    #url = URI("http://integracion-2016-prod.herokuapp.com/bodega/almacenes")
    #DESARROLLO
    url = URI("http://integracion-2016-dev.herokuapp.com/bodega/almacenes")
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

  #------------DESPACHAR---------------#

  def mover_a_bodega(id_producto, id_almacen)
    #PRODUCCION
    #url = URI("http://integracion-2016-prod.herokuapp.com/bodega/moveStock")
    #DESARROLLO
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
    puts "\n MOVIENDO A BODEGA\n"
    puts response.read_body
    puts "END MOVIENDO A BODEGA\n\n"
  end

  def moverProductos(id_oc, almacenId, destinoId, sku, cantidad, faltante, precio)
    #PRODUCCION
    #@almacen_despacho = '572aad42bdb6d403005fb6a0'
    #DESARROLLO
    @almacen_despacho = '571262aba980ba030058a5c7'
    #PRODUCCION
    #url = URI("http://integracion-2016-prod.herokuapp.com/bodega/stock?almacenId=" + almacenId + "&sku=" + sku + "&limit=199" )
    #DESARROLLO
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

  def despachar(id_oc, sku, cantidad, producto, direccion, precio)
    price = precio.to_s
    direccion = "DCC"
    #PRODUCCION
    #url = URI("http://integracion-2016-prod.herokuapp.com/bodega/stock")
    #DESARROLLO
    url = URI("http://integracion-2016-dev.herokuapp.com/bodega/stock")

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Delete.new(url)
    request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    @hashi_get = 'INTEGRACION grupo12:'+generateHash('DELETE'+ producto + direccion + price + id_oc).to_s
    request["authorization"] = @hashi_get
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '4558c91c-6883-428e-39eb-5b51fbc410eb'
    request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"productoId\"\r\n\r\n"+producto+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"direccion\"\r\n\r\n"+direccion+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"precio\"\r\n\r\n"+price+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"oc\"\r\n\r\n"+id_oc+"\r\n-----011000010111000001101001--"

    response = http.request(request)
    puts "\nRESPUESTA DESPACHAR\n"
    puts response.read_body
    puts "END RESPUESTA DESPACHAR\n\n"
  end

def preparar_despacho(id_oc, sku, cantidad, precio, almacen_destino)
    #PRODUCCION
    #almacen_despacho = '572aad42bdb6d403005fb6a0'
    almacen_despacho = '571262aba980ba030058a5c7'
    stock_en_despacho = contarProductos(almacen_despacho, sku)
    if cantidad <= stock_en_despacho
      puts "listos para despachar"
      faltante = cantidad
      while(faltante > 0)
        faltante = moverProductos(id_oc, almacen_despacho, almacen_destino, sku, cantidad, faltante, precio)
      end
      #tablasku = SkuStock.find_by(SKU: sku)
      #tablasku.stock -= cantidad
    else
      puts "Hay " + stock_en_despacho.to_s + " en despacho" 
      puts "debemos mover cosas"
      #PRODUCCION
      #@mis_almacenes = ["572aad42bdb6d403005fb742", "572aad42bdb6d403005fb69f", "572aad42bdb6d403005fb6a1", "572aad42bdb6d403005fb741"]
      #DESARROLLO
      @mis_almacenes = ["571262aba980ba030058a5d6", "571262aba980ba030058a5c6", "571262aba980ba030058a5c8", "571262aba980ba030058a5d7"]
      stock_otras_bodegas = 0
      faltante = cantidad
      ###REVISO SI EN TODOS MIS ALMACENES TENGO STOCK
      @mis_almacenes.each do |almacen|
        stock_otras_bodegas += contarProductos(almacen, sku)
        if cantidad <= stock_otras_bodegas + stock_en_despacho
          break
        end
      end
      ###UNA VEZ CONFIRMADO MI STOCK, MUEVO LOS PRODUCTOS PARA EL DESPACHO
      if cantidad <= stock_otras_bodegas + stock_en_despacho
        puts "Hay stock suficiente"
        while (stock_en_despacho > 0)
          stock_anterior = stock_en_despacho
          stock_en_despacho = moverProductos(id_oc, almacen_despacho, almacen_destino, sku, cantidad, stock_en_despacho, precio)
          faltante -= stock_anterior - stock_en_despacho
        end
          #faltante = moverProductos(id_oc, almacen_despacho, almacen_destino, sku, cantidad, faltante, precio, modo)
          if faltante < 200
            @mis_almacenes.each do |almacen|
              faltante = moverProductos(id_oc, almacen, almacen_destino, sku, cantidad, faltante, precio)
              #faltante = moverProductos(id_oc, almacen, almacen_destino, sku, cantidad, faltante, precio, modo)
              if faltante <= 0
                  break
              end
            end
          else
            @mis_almacenes.each do |almacen|
              stock_almacen = contarProductos(almacen, sku)
              if stock_almacen >= faltante
                while (faltante > 0)
                faltante = moverProductos(id_oc, almacen, almacen_destino, sku, cantidad, faltante, precio)
                if faltante <= 0
                      break
                  end
              end
              else
                while (stock_almacen > 0)
                  stock_anterior = stock_almacen
                  stock_almacen = moverProductos(id_oc, almacen, almacen_destino, sku, cantidad, stock_almacen, precio)
                  faltante -= stock_anterior - stock_almacen
                if faltante <= 0
                      break
                  end
              end
              end
              if faltante <= 0
                  break
              end
            end
          end
          
          puts "despachamos!"
          #tablasku = SkuStock.find_by(SKU: sku)
          #tablasku.stock -= cantidad
          ###despachar()
      else
          puts "NO SE PUEDE DESPACHAR"
          ###NO SE PUEDE DESPACHAR
      end
    end 
  end

  def despacharApi()
    id_boleta=params["id_boleta"].to_s    
    sku=params["sku"].to_s 
    cantidad=params["cantidad"].to_i
    precio = Precio.find_by(SKU:sku).Precio_Unitario    
    direccion=params["direccion"].to_s
    preparar_despacho(id_boleta, sku, cantidad, precio, direccion)
    @response =  {:respuesta => "Preparar Despacho"}
        respond_to do |format|
          format.html {}
          format.json { render :json => @response }
          format.js
    end
  end



  def new

  end

  def urlok
    boleta=params["boletaId"].to_s 
    Boletum.find_by(id_boleta: boleta).estado = "pagada"
    cantidad7 = Boletum.find_by(id_boleta: boleta).cantidad7
    cantidad15 = Boletum.find_by(id_boleta: boleta).cantidad15
    cantidad30 = Boletum.find_by(id_boleta: boleta).cantidad30
    cantidad34 = Boletum.find_by(id_boleta: boleta).cantidad34
    cantidad51 = Boletum.find_by(id_boleta: boleta).cantidad51
    direccion = Boletum.find_by(id_boleta: boleta).direccion
    if cantidad7
      precio = Precio.find_by(SKU:'7').Precio_Unitario    
      preparar_despacho(boleta, '7', cantidad7, precio, direccion)
    end
    if cantidad15
      precio = Precio.find_by(SKU:'15').Precio_Unitario    
      preparar_despacho(boleta, '15', cantidad15, precio, direccion)
    end

    if cantidad30
      precio = Precio.find_by(SKU:'30').Precio_Unitario    
      preparar_despacho(boleta, '30', cantidad30, precio, direccion)
    end

    if cantidad34
      precio = Precio.find_by(SKU:'34').Precio_Unitario    
      preparar_despacho(boleta, '34', cantidad34, precio, direccion)
    end

    if cantidad51
      precio = Precio.find_by(SKU:'51').Precio_Unitario    
      preparar_despacho(boleta, '51', cantidad51, precio, direccion)
    end    

    puts 'hemos despachado yay!'
    Boletum.find_by(id_boleta: boleta).estado = "despachada"

    #contartotal

  end

  def urlfail

  end




  def recibir_compra(nombre, calle, cantidad1, cantidad2, cantidad3, cantidad4, cantidad5)  
      




        begin
            if cantidad1== nil
              @cantidad1=0
            else
              @cantidad1=cantidad1
            end
            if cantidad2== nil
              @cantidad2=0
            else
              @cantidad2=cantidad2
            end
            if cantidad3== nil
              @cantidad3=0
            else
              @cantidad3=cantidad3
            end
            if cantidad4== nil
              @cantidad4=0
            else
              @cantidad4=cantidad4
            end
            if cantidad5== nil
              @cantidad5=0
            else
              @cantidad5=cantidad5
            end

            ###VERIFICAMOS STOCK
            haystock = true

            if !@cantidad1.nil?
              if @cantidad1 > contarTotal('7')
                haystock = false
              end
            end

            if !@cantidad2.nil?
              if @cantidad2 > contarTotal('15')
                haystock = false
              end
            end

            if !@cantidad3.nil?
              if @cantidad3 > contarTotal('30')
                haystock = false
              end
            end

            if !@cantidad4.nil?
              if @cantidad4 > contarTotal('34')
                haystock = false
              end
            end

            if !@cantidad5.nil?
              if @cantidad5 > contarTotal('51')
                haystock = false
              end
            end

            if haystock
              @cliente=nombre
              @direccion=calle


              #CALCULAR TOTAL
              
              @total = 0
              if @cantidad1 > 0
                @precio_unitario1 = Precio.find_by(SKU:'7').Precio_Unitario
                @total += @cantidad1*@precio_unitario1
              end
              
              if @cantidad2 > 0
                @precio_unitario2 = Precio.find_by(SKU:'15').Precio_Unitario
                @total += @cantidad2*@precio_unitario2
              end

              if @cantidad3 > 0
                @precio_unitario3 = Precio.find_by(SKU:'30').Precio_Unitario
                @total += @cantidad3*@precio_unitario3
              end

              if @cantidad4 > 0
                @precio_unitario4 = Precio.find_by(SKU:'34').Precio_Unitario
                @total += @cantidad4*@precio_unitario4
              end

              if @cantidad5 > 0
                @precio_unitario5 = Precio.find_by(SKU:'51').Precio_Unitario
                @total += @cantidad5*@precio_unitario5
              end





              @total = @total.to_s
              #DESARROLLO
              @proveedor = "571262b8a980ba030058ab5a"
              #PRODUCCION
              # @proveedor = "572aac69bdb6d403005fb04d"
              @boleta = generateBoleta(@proveedor, @cliente, @total).to_s
              
              Boletum.create(id_boleta:@boleta, estado:"creada", cantidad7:@cantidad1, cantidad15:@cantidad2, cantidad30:@cantidad3, cantidad34:@cantidad4, cantidad51:@cantidad5, cliente:@cliente, direccion:@direccion)
              #urlok = 'http%3A%2F%2Flocalhost%3A3000%2Fcompraok%3FboletaId%3D'+@boleta+'%26sku%3D'+@sku

              urlok = 'http%3A%2F%2Fdry-beyond-21763.herokuapp.com%2Fcompraok%3FboletaId%3D' + @boleta.to_s
              #urlok = 'http%3A%2F%2Fdry-beyond-21763.herokuapp.com%2Fcompraok%3FboletaId%3D' + @boleta.to_s
              urlfail = 'http%3A%2F%2Fdry-beyond-21763.herokuapp.com%2Fcomprafail'
              #urlfail = 'http%3A%2F%2Fdry-beyond-21763.herokuapp.com%2Fcomprafail'
              url = 'http://integracion-2016-dev.herokuapp.com/web/pagoenlinea?callbackUrl='+urlok+'&cancelUrl='+urlfail+'&boletaId='+@boleta.to_s


      #Spree::StockMovement.create(stock_item_id: 7, quantity: 10)
      #contarTotal('7')
      stock7= Spree::Product.where(name: 'Leche').take.master.stock_items.first.count_on_hand.to_i
      if stock7 > 0
        stock7 = stock7*-1
      else
        stock7 = 0
      end
      stock15=  Spree::Product.where(name: 'Avena').take.master.stock_items.first.count_on_hand.to_i
      if stock15 > 0
        stock15 = stock15*-1
      else
        stock15 = 0
      end      
      stock30=  Spree::Product.where(name: 'Tela de Algodon').take.master.stock_items.first.count_on_hand.to_i 
      if stock30 > 0
        stock30 = stock30*-1
      else
        stock30 = 0
      end      
      stock34=  Spree::Product.where(name: 'Cerveza').take.master.stock_items.first.count_on_hand.to_i
       if stock34 > 0
        stock34 = stock34*-1
      else
        stock34 = 0
      end     
      stock51=  Spree::Product.where(name: 'Pan de Hallulla').take.master.stock_items.first.count_on_hand.to_i
      if stock51 > 0
        stock51 = stock51*-1
      else
        stock51 = 0
      end

      stock7_real = contarTotal('7')
      stock15_real = contarTotal('15')
      stock30_real = contarTotal('30')
      stock34_real = contarTotal('34')
      stock51_real = contarTotal('51')
      puts 'REAL 7: '+ stock7_real.to_s + ', SPREE: ' + stock7.to_s
      puts 'REAL 15: '+ stock15_real.to_s + ', SPREE: ' + stock15.to_s
      puts 'REAL 30: '+ stock30_real.to_s + ', SPREE: ' + stock30.to_s
      puts 'REAL 34: '+ stock34_real.to_s + ', SPREE: ' + stock34.to_s
      puts 'REAL 51: '+ stock51_real.to_s + ', SPREE: ' + stock51.to_s
      
      #Esto esta ahrdoceao para heroku
      id_7= 7
      #fin hardcodeo
      id_15= Spree::Product.where(name: 'Avena').take.id
      id_30= Spree::Product.where(name: 'Tela de Algodon').take.id
      id_34= Spree::Product.where(name: 'Cerveza').take.id
      id_51= Spree::Product.where(name: 'Pan de Hallulla').take.id
      Spree::StockMovement.create(stock_item_id: id_7, quantity: stock7)
      Spree::StockMovement.create(stock_item_id: id_15, quantity: stock15)
      Spree::StockMovement.create(stock_item_id: id_30, quantity: stock30)
      Spree::StockMovement.create(stock_item_id: id_34, quantity: stock34)
      Spree::StockMovement.create(stock_item_id: id_51, quantity: stock51)
      puts 'ID LECHEEE: ' + Spree::Product.where(name: 'Leche').take.id
      Spree::StockMovement.create(stock_item_id: id_7, quantity: stock7_real.to_i)
      Spree::StockMovement.create(stock_item_id: id_15, quantity: stock15_real.to_i)
      Spree::StockMovement.create(stock_item_id: id_30, quantity: stock30_real.to_i)
      Spree::StockMovement.create(stock_item_id: id_34, quantity: stock34_real.to_i)
      Spree::StockMovement.create(stock_item_id: id_51, quantity: stock51_real.to_i)





              redirect_to url
            else
              
              puts "NO HAY SUFICIENTE CANTIDAD"
              redirect_to root_url
            end
        end    
  end





    def show

      @order = Order.find_by_number!(params[:id])
        nombre = @order.ship_address.firstname 
        calle = @order.ship_address.address1
        cantidades = Hash.new
        @order.shipments.each do |ordercita|
          ordercita.manifest.each do |manifiesto|
            puts 'SKU: '+ manifiesto.variant.sku.to_s + ', cantidad:' + manifiesto.quantity.to_s
            if manifiesto.variant.sku.to_s =='7'
              cantidades[7] = manifiesto.quantity.to_i
            elsif manifiesto.variant.sku.to_s =='15'
              cantidades[15] = manifiesto.quantity.to_i
            elsif manifiesto.variant.sku.to_s =='30'
              cantidades[30] = manifiesto.quantity.to_i
            elsif manifiesto.variant.sku.to_s =='34'
              cantidades[34] = manifiesto.quantity.to_i
            elsif manifiesto.variant.sku.to_s =='51'
              cantidades[51] = manifiesto.quantity.to_i
            else     
              cantidades[0] = manifiesto.quantity.to_i     
            end
          end
        end

        recibir_compra(nombre, calle, cantidades[7], cantidades[15], cantidades[30], cantidades[34], cantidades[51]  )
  

    end

    def update

      if @order.contents.update_cart(order_params)
        respond_with(@order) do |format|
          format.html do
            if params.has_key?(:checkout)
              @order.next if @order.cart?
              redirect_to checkout_state_path(@order.checkout_steps.first)
            else
              redirect_to cart_path
            end
          end
        end
      else
        respond_with(@order)
      end
    end

    # Shows the current incomplete order from the session
    def edit
      @order = current_order || Order.incomplete.find_or_initialize_by(guest_token: cookies.signed[:guest_token])
      associate_user
    end

    # Adds a new item to the order (creating a new order if none already exists)
    def populate
      order    = current_order(create_order_if_necessary: true)
      variant  = Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].to_i
      options  = params[:options] || {}

      # 2,147,483,647 is crazy. See issue #2695.
      if quantity.between?(1, 2_147_483_647)
        begin
          order.contents.add(variant, quantity, options)
        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
      else
        error = Spree.t(:please_enter_reasonable_quantity)
      end

      if error
        flash[:error] = error
        redirect_back_or_default(spree.root_path)
      else
        respond_with(order) do |format|
          format.html { redirect_to cart_path }
        end
      end
    end

    def empty
      if @order = current_order
        @order.empty!
      end

      redirect_to spree.cart_path
    end

    def accurate_title
      if @order && @order.completed?
        Spree.t(:order_number, :number => @order.number)
      else
        Spree.t(:shopping_cart)
      end
    end

    def check_authorization
      order = Spree::Order.find_by_number(params[:id]) || current_order

      if order
        authorize! :edit, order, cookies.signed[:guest_token]
      else
        authorize! :create, Spree::Order
      end
    end

    private

      def order_params
        if params[:order]
          params[:order].permit(*permitted_order_attributes)
        else
          {}
        end
      end

      def assign_order_with_lock
        @order = current_order(lock: true)
        unless @order
          flash[:error] = Spree.t(:order_not_found)
          redirect_to root_path and return
        end
      end
  end
end
