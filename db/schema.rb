# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160502171228) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "costos", force: :cascade do |t|
    t.string   "SKU"
    t.string   "Descripcion"
    t.integer  "Lote"
    t.string   "Unidad"
    t.string   "SKU_Ingrediente"
    t.string   "Ingrediente"
    t.integer  "Requerimiento"
    t.integer  "Precio_Ingrediente"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "oc_rcibidas", force: :cascade do |t|
    t.string   "id_dev"
    t.date     "created_at_dev"
    t.string   "canal"
    t.string   "sku"
    t.integer  "cantidad"
    t.integer  "precio_unit"
    t.date     "entrega_at"
    t.date     "despacho_at"
    t.string   "estado"
    t.string   "rechazo"
    t.string   "anulacion"
    t.string   "notas"
    t.string   "id_factura_dev"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "oc_recibidas", force: :cascade do |t|
    t.string   "id_dev"
    t.date     "created_at_dev"
    t.string   "canal"
    t.string   "sku"
    t.integer  "cantidad"
    t.integer  "precio_unit"
    t.date     "entrega_at"
    t.date     "despacho_at"
    t.string   "estado"
    t.string   "rechazo"
    t.string   "anulacion"
    t.string   "notas"
    t.string   "id_factura_dev"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "cliente"
    t.string   "proveedor"
    t.integer  "fechaEntrega"
  end

  create_table "precios", force: :cascade do |t|
    t.string   "SKU"
    t.string   "Descripción"
    t.integer  "Precio_Unitario"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "produccions", force: :cascade do |t|
    t.string   "id_dev"
    t.string   "created_at_dev"
    t.date     "fecha_termino"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "sku_stocks", force: :cascade do |t|
    t.string   "SKU"
    t.integer  "stock"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "title"
    t.text     "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tiempos", force: :cascade do |t|
    t.string   "SKU"
    t.string   "Descripción"
    t.string   "Tipo"
    t.integer  "Grupo_Proyecto"
    t.string   "Unidades"
    t.integer  "Costo_produccion_unitario"
    t.integer  "Lote_Produccion"
    t.integer  "Tiempo_Medio_Producción"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
