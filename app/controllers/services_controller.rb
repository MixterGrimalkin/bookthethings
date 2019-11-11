class ServicesController < ApplicationController

  before_action :providers_only

  API_KEYS = [:name, :description, :min_length, :max_length, :booking_resolution]

  def get_services
    json_response(@current_user.provider.services.select(:id, *API_KEYS))
  end

  def create_service
    service = Service.create!(params.permit(*API_KEYS))
    @current_user.provider.services << service
    json_response({id: service.id, message: 'Service created'})
  end

  def update_service
    service = Service.find(params[:service_id])
    must_be_provided(service)
    service.update!(params.permit(*API_KEYS))
    json_response('OK')
  end

  def add_service
    service = Service.find(params[:service_id])
    must_not_be_provided(service)
    @current_user.provider.services << service
    json_response('Service added')
  end

  def remove_service
    service = Service.find(params[:service_id])
    must_be_provided(service)
    @current_user.provider.services -= [service]
    json_response('Service removed')
  end

  private

  def must_be_provided(service)
    unless @current_user.provider.services.include? service
      raise ExceptionHandler::RelationshipError.new('Service not provided')
    end
  end

  def must_not_be_provided(service)
    if @current_user.provider.services.include? service
      raise ExceptionHandler::RelationshipError.new('Service already provided')
    end
  end

end
