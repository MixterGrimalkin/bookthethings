class CustomersController < ApplicationController

  before_action :customers_only

  def details
    data = {
        name: @current_user.name,
        email: @current_user.email,
        phone: @current_user.phone,
        locations: [],
        registered_with_companies: [],
        bookings: []
    }
    @current_user.customer.locations.each do |location|
      data[:locations] << {
          id: location.id,
          street_address: location.street_address,
          postcode: location.postcode
      }
    end
    @current_user.customer.companies.each do |company|
      data[:registered_with_companies] << {
          id: company.id,
          name: company.name,
          slug: company.slug,
          description: company.description,
          login_html: company.login_html
      }
    end
    json_response(data)
  end

end
