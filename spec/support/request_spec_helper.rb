module RequestSpecHelper

  def json
    JSON.parse(response.body)
  end

  def compare_users(user, api_obj)
    compare_objects([:name, :email, :phone], user, api_obj)
  end

  def compare_locations(location, api_obj)
    compare_objects([:id, :street_address, :postcode], location, api_obj)
  end

  def compare_companies(company, api_obj)
    compare_objects([:id, :name, :slug, :description, :login_html], company, api_obj)
  end

  def compare_objects(keys, db_obj, api_obj)
    result = true
    keys.each do |key|
      result &= db_obj.send(key) == api_obj[key.to_s]
    end
    result
  end

end