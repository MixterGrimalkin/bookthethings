module RequestSpecHelper

  def json
    JSON.parse(response.body)
  end

  def compare_users(api_obj, user, ignore_keys = [])
    keys = [:name, :email, :phone]
    compare_objects(keys, api_obj, user, ignore_keys)
  end

  def compare_locations(api_obj, location, ignore_keys = [])
    keys = [:id, :street_address, :postcode]
    compare_objects(keys, api_obj, location, ignore_keys)
  end

  def compare_companies(api_obj, company, ignore_keys = [])
    keys = [:id, :name, :slug, :description, :login_html]
    compare_objects(keys, api_obj, company, ignore_keys)
  end

  def compare_services(api_obj, service, ignore_keys = [])
    keys = [:id, :name, :description, :min_length, :max_length, :booking_resolution]
    compare_objects(keys, api_obj, service, ignore_keys)
  end

  def compare_objects(keys, api_obj, db_obj, ignore_keys = [])
    result = true
    keys.each do |key|
      unless ignore_keys.include? key
        result &= db_obj.send(key) == api_obj[key.to_s]
      end
    end
    result
  end


end