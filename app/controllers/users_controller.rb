class UsersController < ApplicationController

  skip_before_action :authorize_request, only: :create

  def create
    user = User.create!(user_params)
    auth_token = AuthenticateUser.new(user.email, user.password).call
    response = {message: Message.account_created, auth_token: auth_token}
    json_response(response, :created)
  end

  def user_details
    json_response(
        {
            name: @current_user.name,
            email: @current_user.email,
            phone: @current_user.phone,
            is_customer: !@current_user.customer.nil?,
            is_provider: !@current_user.provider.nil?
        }
    )
  end

  private

  def user_params
    params.permit(
        :name,
        :email,
        :phone,
        :password,
        :password_confirmation
    )
  end

end