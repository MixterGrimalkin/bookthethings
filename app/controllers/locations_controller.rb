class LocationsController < ApplicationController

  before_action :customers_only, only: :link_customer
  before_action :providers_only, only: :link_provider

  def get_locations
    data = {}
    if (customer = @current_user.customer)
      data[:customer] = customer.locations.select(:id, :street_address, :postcode)
    end
    if (provider = @current_user.provider)
      data[:provider] = provider.locations.select(:id, :street_address, :postcode)
    end
    json_response(data)
  end

  def create_location
    location = Location.create!(params.permit(:street_address, :postcode))
    json_response({message: 'Location created', id: location.id})
  end

  def update_location
    location = Location.find(params[:id])
    location.update!(params.permit(:street_address, :postcode))
    json_response({message: 'Location updated'})
  end

  def link_customer
    location = Location.find(params[:id])
    customer = @current_user.customer
    if customer.locations.include? location
      return json_response({message: 'Location already added'}, :bad_request)
    end
    customer.locations << location
    json_response({message: 'Added customer location'})
  end

  def link_provider
    location = Location.find(params[:id])
    provider = @current_user.provider
    if provider.locations.include? location
      return json_response({message: 'Location already added'}, :bad_request)
    end
    provider.locations << location
    json_response({message: 'Added provider location'})
  end

end
