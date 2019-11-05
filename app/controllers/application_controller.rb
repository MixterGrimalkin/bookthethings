class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    @current_user = (AuthorizeApiRequest.new(request.headers).call)[:user]
  end

  def customers_only
    raise(ActiveRecord::RecordNotFound, 'User is not a customer') unless @current_user.customer
  end

end
