require 'test_helper'

class Sp500CompaniesControllerTest < ActionController::TestCase
  setup do
    @sp500_company = sp500_companies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sp500_companies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sp500_company" do
    assert_difference('Sp500Company.count') do
      post :create, sp500_company: { company_name: @sp500_company.company_name, gics_sector: @sp500_company.gics_sector, gics_sub_industry: @sp500_company.gics_sub_industry, headquarters_city: @sp500_company.headquarters_city, sec_filings: @sp500_company.sec_filings, sp500_added_date: @sp500_company.sp500_added_date, symbol: @sp500_company.symbol }
    end

    assert_redirected_to sp500_company_path(assigns(:sp500_company))
  end

  test "should show sp500_company" do
    get :show, id: @sp500_company
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sp500_company
    assert_response :success
  end

  test "should update sp500_company" do
    put :update, id: @sp500_company, sp500_company: { company_name: @sp500_company.company_name, gics_sector: @sp500_company.gics_sector, gics_sub_industry: @sp500_company.gics_sub_industry, headquarters_city: @sp500_company.headquarters_city, sec_filings: @sp500_company.sec_filings, sp500_added_date: @sp500_company.sp500_added_date, symbol: @sp500_company.symbol }
    assert_redirected_to sp500_company_path(assigns(:sp500_company))
  end

  test "should destroy sp500_company" do
    assert_difference('Sp500Company.count', -1) do
      delete :destroy, id: @sp500_company
    end

    assert_redirected_to sp500_companies_path
  end
end
