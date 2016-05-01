require 'test_helper'

class OcRecibidasControllerTest < ActionController::TestCase
  setup do
    @oc_recibida = oc_recibidas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:oc_recibidas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create oc_recibida" do
    assert_difference('OcRecibida.count') do
      post :create, oc_recibida: { anulacion: @oc_recibida.anulacion, canal: @oc_recibida.canal, cantidad: @oc_recibida.cantidad, created_at_dev: @oc_recibida.created_at_dev, despacho_at: @oc_recibida.despacho_at, entrega_at: @oc_recibida.entrega_at, estado: @oc_recibida.estado, id_dev: @oc_recibida.id_dev, id_factura_dev: @oc_recibida.id_factura_dev, notas: @oc_recibida.notas, precio_unit: @oc_recibida.precio_unit, rechazo: @oc_recibida.rechazo, sku: @oc_recibida.sku }
    end

    assert_redirected_to oc_recibida_path(assigns(:oc_recibida))
  end

  test "should show oc_recibida" do
    get :show, id: @oc_recibida
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @oc_recibida
    assert_response :success
  end

  test "should update oc_recibida" do
    patch :update, id: @oc_recibida, oc_recibida: { anulacion: @oc_recibida.anulacion, canal: @oc_recibida.canal, cantidad: @oc_recibida.cantidad, created_at_dev: @oc_recibida.created_at_dev, despacho_at: @oc_recibida.despacho_at, entrega_at: @oc_recibida.entrega_at, estado: @oc_recibida.estado, id_dev: @oc_recibida.id_dev, id_factura_dev: @oc_recibida.id_factura_dev, notas: @oc_recibida.notas, precio_unit: @oc_recibida.precio_unit, rechazo: @oc_recibida.rechazo, sku: @oc_recibida.sku }
    assert_redirected_to oc_recibida_path(assigns(:oc_recibida))
  end

  test "should destroy oc_recibida" do
    assert_difference('OcRecibida.count', -1) do
      delete :destroy, id: @oc_recibida
    end

    assert_redirected_to oc_recibidas_path
  end
end
