class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  before_action :authorize_request

  attr_reader :current_user

  private

  COMPANY_API_KEYS = [:name, :slug, :description, :login_html]
  LOCATION_API_KEYS = [:street_address, :postcode]
  SERVICE_API_KEYS = [:name, :description, :min_length, :max_length, :booking_resolution, :color]
  RATE_API_KEYS = [:day, :start_time, :end_time, :cost_amount, :cost_per]

  def authorize_request
    @current_user = (AuthorizeApiRequest.new(request.headers).call)[:user]
  end

  def customers_only
    raise(ExceptionHandler::WrongUserType, 'User is not a customer') unless @current_user.customer
  end

  def providers_only
    raise(ExceptionHandler::WrongUserType, 'User is not a provider') unless @current_user.provider
  end

end
