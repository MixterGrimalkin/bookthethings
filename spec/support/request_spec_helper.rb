module RequestSpecHelper

  PUTS_COMPARISON_ERRORS = false

  def json
    JSON.parse(response.body)
  end

  def compare_users(api_obj, user, ignore_keys = [])
    keys = [:name, :email, :phone]
    compare_objects(keys, api_obj, user, ignore_keys)
  end

  def compare_locations(api_obj, location, ignore_keys = [])
    keys = [:id, *ApplicationController::LOCATION_API_KEYS]
    compare_objects(keys, api_obj, location, ignore_keys)
  end

  def compare_companies(api_obj, company, ignore_keys = [])
    keys = [:id, *ApplicationController::COMPANY_API_KEYS]
    compare_objects(keys, api_obj, company, ignore_keys)
  end

  def compare_services(api_obj, service, ignore_keys = [])
    keys = [:id, *ApplicationController::SERVICE_API_KEYS]
    compare_objects(keys, api_obj, service, ignore_keys)
  end

  def compare_rates(api_obj, rate, ignore_keys = [])
    keys = [:id, *ApplicationController::RATE_API_KEYS]
    compare_objects(keys, api_obj, rate, ignore_keys)
  end

  def compare_objects(keys, api_obj, db_obj, ignore_keys = [])
    result = true
    keys.each do |key|
      unless ignore_keys.include? key
        result &= db_obj.send(key) == api_obj[key.to_s]
        unless result || !PUTS_COMPARISON_ERRORS
          puts "Object comparison error: #{key.to_s} (#{api_obj[key.to_s]} != #{db_obj.send(key)})"
        end
      end
    end
    result
  end


end