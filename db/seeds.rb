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
		lineas = line.split(';')
		lineas.each do |contenido|
			Costo.create( 
				 SKU: contenido[0],Descripcion: contenido[1],
				 Lote: contenido[2],
				 Unidad: contenido[3],
				 SKU_Ingrediente: contenido[4],
				 Ingrediente: contenido[5],
				 Requerimiento: contenido[6],
				 Unidad: contenido[7],
				 Precio_Ingrediente: contenido[8]
			)
		end

	end
end

File.open("./init/precio_venta.csv", "r") do |f|
	f.each_line do |line|
	if ! line.valid_encoding?
	  line = line.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
	end	
		lineas = line.split(';')
		lineas.each do |contenido|
			Precio.create( 

				 SKU: contenido[0],
				 Descripción: contenido[2],
				 Precio_Unitario: contenido[3],
			)
		end

	end
end




File.open("./init/tiempos.csv", "r") do |f|
	f.each_line do |line|
	if ! line.valid_encoding?
	  line = line.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
	end	
		lineas = line.split(';')
		lineas.each do |contenido|
			Tiempo.create( 
				 SKU: contenido[0],
				 Descripción: contenido[2],
				 Tipo: contenido[3],
				 Grupo_Proyecto: contenido[4],
				 Unidades: contenido[5],
				 Costo_produccion_unitario: contenido[6],
				 Lote_Produccion: contenido[7],
				 Tiempo_Medio_Producción: contenido[8]
			)
		end

	end
end




