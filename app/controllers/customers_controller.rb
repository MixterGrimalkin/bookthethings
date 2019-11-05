class CustomersController < ApplicationController

  before_action :customers_only

  def details
    json_response(
        {
            name: @current_user.name,
            email: @current_user.email,
            phone: @current_user.phone
        }
    )
  end

  def locations
    json_response(
        @current_user.customer.locations.collect do |location|
          {
              id: location.id,
              street_address: location.street_address,
              postcode: location.postcode
          }
        end
    )
  end

  def companies
    json_response(
        @current_user.customer.companies.collect do |company|
          {
              id: company.id,
              name: company.name,
              slug: company.slug,
              description: company.description,
              login_html: company.login_html
          }
        end
    )
  end

end
