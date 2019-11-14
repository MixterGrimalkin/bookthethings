class RatesController < ApplicationController

  before_action :providers_only
  before_action :must_provide_service, except: :get_all_rates

  API_KEYS = [:day, :start_time, :end_time, :cost_amount, :cost_per]
  SERVICE_API_KEYS = [:name, :description, :min_length, :max_length, :booking_resolution]

  def get_all_rates
    data = []
    @current_user.provider.services.each do |service|
      service_data = {id: service.id, rates: []}
      SERVICE_API_KEYS.each do |key|
        service_data[key] = service.send(key)
      end
      service.rates.each do |rate|
        rate_data = {id: rate.id}
        API_KEYS.each do |key|
          rate_data[key] = rate.send(key)
        end
        service_data[:rates] << rate_data
      end
      data << service_data
    end
    json_response(data)
  end

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
