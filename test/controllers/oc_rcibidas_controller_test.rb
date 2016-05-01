require 'test_helper'

class OcRcibidasControllerTest < ActionController::TestCase
  setup do
    @oc_rcibida = oc_rcibidas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:oc_rcibidas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create oc_rcibida" do
    assert_difference('OcRcibida.count') do
      post :create, oc_rcibida: { anulacion: @oc_rcibida.anulacion, canal: @oc_rcibida.canal, cantidad: @oc_rcibida.cantidad, created_at_dev: @oc_rcibida.created_at_dev, despacho_at: @oc_rcibida.despacho_at, entrega_at: @oc_rcibida.entrega_at, estado: @oc_rcibida.estado, id_dev: @oc_rcibida.id_dev, id_factura_dev: @oc_rcibida.id_factura_dev, notas: @oc_rcibida.notas, precio_unit: @oc_rcibida.precio_unit, rechazo: @oc_rcibida.rechazo, sku: @oc_rcibida.sku }
    end

    assert_redirected_to oc_rcibida_path(assigns(:oc_rcibida))
  end

  test "should show oc_rcibida" do
    get :show, id: @oc_rcibida
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @oc_rcibida
    assert_response :success
  end

  test "should update oc_rcibida" do
    patch :update, id: @oc_rcibida, oc_rcibida: { anulacion: @oc_rcibida.anulacion, canal: @oc_rcibida.canal, cantidad: @oc_rcibida.cantidad, created_at_dev: @oc_rcibida.created_at_dev, despacho_at: @oc_rcibida.despacho_at, entrega_at: @oc_rcibida.entrega_at, estado: @oc_rcibida.estado, id_dev: @oc_rcibida.id_dev, id_factura_dev: @oc_rcibida.id_factura_dev, notas: @oc_rcibida.notas, precio_unit: @oc_rcibida.precio_unit, rechazo: @oc_rcibida.rechazo, sku: @oc_rcibida.sku }
    assert_redirected_to oc_rcibida_path(assigns(:oc_rcibida))
  end

  test "should destroy oc_rcibida" do
    assert_difference('OcRcibida.count', -1) do
      delete :destroy, id: @oc_rcibida
    end

    assert_redirected_to oc_rcibidas_path
  end
end
