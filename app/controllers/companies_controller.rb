class CompaniesController < ApplicationController

  def all
    @companies = Company.all
    json_response(@companies)
  end

  def one
    @company = Company.find(params[:id])
    json_response(@company)
  end

end
