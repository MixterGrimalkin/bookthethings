class Availability < ApplicationRecord
  validates_presence_of :start_date, :end_date

  belongs_to :provider

  belongs_to :base_location, class_name: 'Location', foreign_key: 'base_location_id'

  has_many :availability_services
  has_many :services, through: :availability_services

  has_many :availability_rates
  has_many :rates, through: :availability_rates

  has_many :availability_locations
  has_many :locations, through: :availability_locations

end
