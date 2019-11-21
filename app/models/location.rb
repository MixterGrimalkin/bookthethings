class Location < ApplicationRecord
  validates_presence_of :street_address, :postcode

  has_many :bookings

  has_many :customer_locations
  has_many :customers, through: :customer_locations

  has_many :provider_locations
  has_many :providers, through: :provider_locations

end
