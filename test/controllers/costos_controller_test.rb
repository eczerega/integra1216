require 'test_helper'

class CostosControllerTest < ActionController::TestCase
  setup do
    @costo = costos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:costos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create costo" do
    assert_difference('Costo.count') do
      post :create, costo: { Descripcion: @costo.Descripcion, Ingrediente: @costo.Ingrediente, Ingrediente: @costo.Ingrediente, Lote: @costo.Lote, Precio_Ingrediente: @costo.Precio_Ingrediente, Requerimiento: @costo.Requerimiento, SKU: @costo.SKU, SKU_Ingrediente: @costo.SKU_Ingrediente, Unidad: @costo.Unidad, Unidad: @costo.Unidad }
    end

    assert_redirected_to costo_path(assigns(:costo))
  end

  test "should show costo" do
    get :show, id: @costo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @costo
    assert_response :success
  end

  test "should update costo" do
    patch :update, id: @costo, costo: { Descripcion: @costo.Descripcion, Ingrediente: @costo.Ingrediente, Ingrediente: @costo.Ingrediente, Lote: @costo.Lote, Precio_Ingrediente: @costo.Precio_Ingrediente, Requerimiento: @costo.Requerimiento, SKU: @costo.SKU, SKU_Ingrediente: @costo.SKU_Ingrediente, Unidad: @costo.Unidad, Unidad: @costo.Unidad }
    assert_redirected_to costo_path(assigns(:costo))
  end

  test "should destroy costo" do
    assert_difference('Costo.count', -1) do
      delete :destroy, id: @costo
    end

    assert_redirected_to costos_path
  end
end
