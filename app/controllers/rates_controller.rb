class RatesController < ApplicationController

  before_action :providers_only
  before_action :must_provide_service, except: :get_all_rates

  def get_all_rates
    data = []
    @current_user.provider.services.each do |service|
      service_data = {id: service.id, rates: []}
      SERVICE_API_KEYS.each do |key|
        service_data[key] = service.send(key)
      end
      service.rates.each do |rate|
        rate_data = {id: rate.id}
        RATE_API_KEYS.each do |key|
          rate_data[key] = rate.send(key)
        end
        service_data[:rates] << rate_data
      end
      data << service_data
    end
    json_response(data)
  end

  def get_rates
    json_response(@service.rates.select(:id, :service_id, *RATE_API_KEYS).to_json)
  end

  def create_rate
    config = params.permit(*RATE_API_KEYS)
    config[:service] = @service
    rate = Rate.create!(config)
    json_response({message: 'Rate created', id: rate.id})
  end

  def update_rate
    rate = @service.rates.find(params[:rate_id])
    rate.update!(params.permit(*RATE_API_KEYS))
    json_response({message: 'Rate updated'})
  end

  def delete_rate
    rate = @service.rates.find(params[:rate_id])
    rate.delete
    json_response({message: 'Rate deleted'})
  end

  def fill_days
    rate = @service.rates.find(params[:rate_id])
    days = params[:days] || []
    if days.empty?
      return json_response({message: 'Must specify days to fill'}, :bad_request)
    end
    count = 0
    days.each do |day|
      begin
        new_rate = rate.dup
        new_rate.day = day
        new_rate.save!
        @service.rates << new_rate
        count += 1
      rescue ActiveRecord::RecordInvalid
        # Ignore clashes
      end
    end
    json_response({message: "Created #{count} rates"})
  end

  private

  def must_provide_service
    @service = Service.find(params[:service_id])
    unless @current_user.provider.services.include? @service
      raise ExceptionHandler::RelationshipError.new('Service not provided')
    end
  end

end
