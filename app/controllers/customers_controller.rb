require 'securerandom'

class CustomersController < ApplicationController

  before_action :customers_only, except: :request_customership

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
    json_response(@current_user.customer.locations.select(:id, *LOCATION_API_KEYS))
  end

  def companies
    json_response(@current_user.customer.companies.select(:id, *COMPANY_API_KEYS))
  end

  def request_customership
    if @current_user.customer && @current_user.customer.invite_key.nil?
      return json_response('User is already a customer', 400)
    end
    invite_key = SecureRandom.hex(16)
    if (customer = @current_user.customer)
      customer.invite_key = invite_key
      customer.save
    else
      Customer.create(user: @current_user, invite_key: invite_key)
    end
    json_response(
        {
            message: 'Requested Customer status for User',
            invite_key: invite_key
        }
    )
  end

  def enable_customership
    customer = @current_user.customer
    if customer.invite_key.nil?
      return json_response('User is already a customer', 400)
    end
    if customer.invite_key != params[:invite_key]
      return json_response('Invalid invite key', 400)
    end
    customer.invite_key = nil
    customer.save
    json_response({message: 'User is now a customer'})
  end

end
