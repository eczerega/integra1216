# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#rails g scaffold tiempos SKU:string Descripción:string Tipo:string Grupo_Proyecto:integer Unidades:string Costo_produccion_unitario:integer Lote_Produccion:integer Tiempo_Medio_Producción:integer
#rails g scaffold costos SKU:string Descripcion:string Lote:integer Unidad:string SKU_Ingrediente:string Ingrediente:string Requerimiento:integer Unidad Ingrediente:string Precio_Ingrediente:integer 
#rails g scaffold precios SKU:string	Descripción:string Precio_Unitario:integer

Costo.create(SKU: 1)

File.open("./init/costos.csv", "r") do |f|
	f.each_line do |line|
	if ! line.valid_encoding?
	  line = line.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
	end	
		contenido = line.split(';')
			Costo.create( 
				 SKU: contenido[0].to_s,
				 Descripcion: contenido[1].to_s,
				 Lote: contenido[2].to_i,
				 Unidad: contenido[3].to_s,
				 SKU_Ingrediente: contenido[4].to_s,
				 Ingrediente: contenido[5].to_s,
				 Requerimiento: contenido[6].to_s,
				 Unidad: contenido[7].to_s,
				 Precio_Ingrediente: contenido[8].to_i
			)

	end
end

File.open("./init/precio_venta.csv", "r") do |f|
	f.each_line do |line|
	if ! line.valid_encoding?
	  line = line.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
	end	
		contenido = line.split(';')
			Precio.create( 

				 SKU: contenido[0].to_s,
				 Descripción: contenido[1].to_s,
				 Precio_Unitario: contenido[2].to_i,
			)
			SkuStock.create(SKU: contenido[0].to_s, stock: 0)
	end
end




File.open("./init/tiempos.csv", "r") do |f|
	f.each_line do |line|
	if ! line.valid_encoding?
	  line = line.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
	end	
		contenido = line.split(';')
			Tiempo.create( 
				 SKU: contenido[0].to_s,
				 Descripción: contenido[1].to_s,
				 Tipo: contenido[2].to_s,
				 Grupo_Proyecto: contenido[3].to_i,
				 Unidades: contenido[4].to_s,
				 Costo_produccion_unitario: contenido[5].to_f,
				 Lote_Produccion: contenido[6].to_i,
				 Tiempo_Medio_Producción: contenido[7].to_f
			)
	end
end

File.open("./init/datos_grupos.csv", "r") do |f|
	f.each_line do |line|
	if ! line.valid_encoding?
	  line = line.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
	end	
		contenido = line.split(';')
			InfoGrupo.create( 
				 num_grupo: contenido[0].to_s,
				 id_grupo: contenido[1].to_s,
				 id_banco: contenido[2].to_s,
				 id_almacen: contenido[3].to_s,
				 ambiente: contenido[4].to_s
			)
	end
end




