require 'test_helper'

class TiemposControllerTest < ActionController::TestCase
  setup do
    @tiempo = tiempos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tiempos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tiempo" do
    assert_difference('Tiempo.count') do
      post :create, tiempo: { Costo_produccion_unitario: @tiempo.Costo_produccion_unitario, Descripción: @tiempo.Descripción, Grupo_Proyecto: @tiempo.Grupo_Proyecto, Lote_Produccion: @tiempo.Lote_Produccion, SKU: @tiempo.SKU, Tiempo_Medio_Producción: @tiempo.Tiempo_Medio_Producción, Tipo: @tiempo.Tipo, Unidades: @tiempo.Unidades }
    end

    assert_redirected_to tiempo_path(assigns(:tiempo))
  end

  test "should show tiempo" do
    get :show, id: @tiempo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tiempo
    assert_response :success
  end

  test "should update tiempo" do
    patch :update, id: @tiempo, tiempo: { Costo_produccion_unitario: @tiempo.Costo_produccion_unitario, Descripción: @tiempo.Descripción, Grupo_Proyecto: @tiempo.Grupo_Proyecto, Lote_Produccion: @tiempo.Lote_Produccion, SKU: @tiempo.SKU, Tiempo_Medio_Producción: @tiempo.Tiempo_Medio_Producción, Tipo: @tiempo.Tipo, Unidades: @tiempo.Unidades }
    assert_redirected_to tiempo_path(assigns(:tiempo))
  end

  test "should destroy tiempo" do
    assert_difference('Tiempo.count', -1) do
      delete :destroy, id: @tiempo
    end

    assert_redirected_to tiempos_path
  end
end
