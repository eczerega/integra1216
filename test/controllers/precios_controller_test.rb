require 'test_helper'

class PreciosControllerTest < ActionController::TestCase
  setup do
    @precio = precios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:precios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create precio" do
    assert_difference('Precio.count') do
      post :create, precio: { Descripción: @precio.Descripción, Precio_Unitario: @precio.Precio_Unitario, SKU: @precio.SKU }
    end

    assert_redirected_to precio_path(assigns(:precio))
  end

  test "should show precio" do
    get :show, id: @precio
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @precio
    assert_response :success
  end

  test "should update precio" do
    patch :update, id: @precio, precio: { Descripción: @precio.Descripción, Precio_Unitario: @precio.Precio_Unitario, SKU: @precio.SKU }
    assert_redirected_to precio_path(assigns(:precio))
  end

  test "should destroy precio" do
    assert_difference('Precio.count', -1) do
      delete :destroy, id: @precio
    end

    assert_redirected_to precios_path
  end
end
