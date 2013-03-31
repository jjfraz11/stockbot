class Sp500CompaniesController < ApplicationController
  # GET /sp500_companies
  # GET /sp500_companies.json
  def index
    @sp500_companies = Sp500Company.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sp500_companies }
    end
  end

  # GET /sp500_companies/1
  # GET /sp500_companies/1.json
  def show
    @sp500_company = Sp500Company.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sp500_company }
    end
  end

  # GET /sp500_companies/new
  # GET /sp500_companies/new.json
  def new
    @sp500_company = Sp500Company.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sp500_company }
    end
  end

  # GET /sp500_companies/1/edit
  def edit
    @sp500_company = Sp500Company.find(params[:id])
  end

  # POST /sp500_companies
  # POST /sp500_companies.json
  def create
    @sp500_company = Sp500Company.new(params[:sp500_company])

    respond_to do |format|
      if @sp500_company.save
        format.html { redirect_to @sp500_company, notice: 'Sp500 company was successfully created.' }
        format.json { render json: @sp500_company, status: :created, location: @sp500_company }
      else
        format.html { render action: "new" }
        format.json { render json: @sp500_company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sp500_companies/1
  # PUT /sp500_companies/1.json
  def update
    @sp500_company = Sp500Company.find(params[:id])

    respond_to do |format|
      if @sp500_company.update_attributes(params[:sp500_company])
        format.html { redirect_to @sp500_company, notice: 'Sp500 company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sp500_company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sp500_companies/1
  # DELETE /sp500_companies/1.json
  def destroy
    @sp500_company = Sp500Company.find(params[:id])
    @sp500_company.destroy

    respond_to do |format|
      format.html { redirect_to sp500_companies_url }
      format.json { head :no_content }
    end
  end
end
