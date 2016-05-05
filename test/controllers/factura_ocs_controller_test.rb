require 'test_helper'

class FacturaOcsControllerTest < ActionController::TestCase
  setup do
    @factura_oc = factura_ocs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:factura_ocs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create factura_oc" do
    assert_difference('FacturaOc.count') do
      post :create, factura_oc: { estado: @factura_oc.estado, factura_id: @factura_oc.factura_id, oc_id: @factura_oc.oc_id }
    end

    assert_redirected_to factura_oc_path(assigns(:factura_oc))
  end

  test "should show factura_oc" do
    get :show, id: @factura_oc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @factura_oc
    assert_response :success
  end

  test "should update factura_oc" do
    patch :update, id: @factura_oc, factura_oc: { estado: @factura_oc.estado, factura_id: @factura_oc.factura_id, oc_id: @factura_oc.oc_id }
    assert_redirected_to factura_oc_path(assigns(:factura_oc))
  end

  test "should destroy factura_oc" do
    assert_difference('FacturaOc.count', -1) do
      delete :destroy, id: @factura_oc
    end

    assert_redirected_to factura_ocs_path
  end
end
