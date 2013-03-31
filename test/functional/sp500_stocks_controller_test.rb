require 'test_helper'

class Sp500StocksControllerTest < ActionController::TestCase
  setup do
    @sp500_stock = sp500_stocks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sp500_stocks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sp500_stock" do
    assert_difference('Sp500Stock.count') do
      post :create, sp500_stock: { company_name: @sp500_stock.company_name, gics_sector: @sp500_stock.gics_sector, gics_sub_industry: @sp500_stock.gics_sub_industry, headquarters_city: @sp500_stock.headquarters_city, sec_filings: @sp500_stock.sec_filings, sp500_added_date: @sp500_stock.sp500_added_date, symbol: @sp500_stock.symbol }
    end

    assert_redirected_to sp500_stock_path(assigns(:sp500_stock))
  end

  test "should show sp500_stock" do
    get :show, id: @sp500_stock
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sp500_stock
    assert_response :success
  end

  test "should update sp500_stock" do
    put :update, id: @sp500_stock, sp500_stock: { company_name: @sp500_stock.company_name, gics_sector: @sp500_stock.gics_sector, gics_sub_industry: @sp500_stock.gics_sub_industry, headquarters_city: @sp500_stock.headquarters_city, sec_filings: @sp500_stock.sec_filings, sp500_added_date: @sp500_stock.sp500_added_date, symbol: @sp500_stock.symbol }
    assert_redirected_to sp500_stock_path(assigns(:sp500_stock))
  end

  test "should destroy sp500_stock" do
    assert_difference('Sp500Stock.count', -1) do
      delete :destroy, id: @sp500_stock
    end

    assert_redirected_to sp500_stocks_path
  end
end
