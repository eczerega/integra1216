# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

rails g scaffold tiempos SKU:string Descripción:string Tipo:string Grupo_Proyecto:integer Unidades:string Costo_produccion_unitario:integer Lote_Produccion:integer Tiempo_Medio_Producción:integer
rails g scaffold costos SKU:string Descripcion:string Lote:integer Unidad:string SKU_Ingrediente:string Ingrediente:string Requerimiento:integer Unidad Ingrediente:string Precio_Ingrediente:integer 
rails g scaffold precios SKU:string	Descripción:string Precio_Unitario:integer