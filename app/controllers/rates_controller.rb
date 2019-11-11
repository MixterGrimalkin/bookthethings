class RatesController < ApplicationController

  before_action :providers_only
  before_action :must_provide_service

  API_KEYS = [:day, :start_time, :end_time, :cost_amount, :cost_per]

  def get_rates
    json_response(@service.rates.select(:id, :service_id, *API_KEYS).to_json)
  end

  def create_rate
    config = params.permit(*API_KEYS)
    config[:service] = @service
    rate = Rate.create!(config)
    json_response({message: 'Rate created', id: rate.id})
  end

  def update_rate
    rate = @service.rates.find(params[:rate_id])
    rate.update!(params.permit(*API_KEYS))
    json_response({message: 'Rate updated'})
  end

  def delete_rate
    rate = @service.rates.find(params[:rate_id])
    rate.delete
    json_response({message: 'Rate deleted'})
  end

  private

  def must_provide_service
    @service = Service.find(params[:service_id])
    unless @current_user.provider.services.include? @service
      raise ExceptionHandler::RelationshipError.new('Service not provided')
    end
  end

end
