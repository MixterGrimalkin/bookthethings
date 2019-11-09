module RequestSpecHelper

  def json
    JSON.parse(response.body)
  end

  def compare_users(api_obj, user)
    compare_objects([:name, :email, :phone], api_obj, user)
  end

  def compare_locations(api_obj, location)
    compare_objects([:id, :street_address, :postcode], api_obj, location)
  end

  def compare_companies(api_obj, company)
    compare_objects([:id, :name, :slug, :description, :login_html], api_obj, company)
  end

  def compare_services(api_obj, service)
    compare_objects([:id, :name, :description], api_obj, service)
  end

  def compare_objects(keys, api_obj, db_obj)
    result = true
    keys.each do |key|
      result &= db_obj.send(key) == api_obj[key.to_s]
    end
    result
  end


end