class Provider < ApplicationRecord
  validates_presence_of :name, :email, :company

  belongs_to :company

  has_many :provider_services
  has_many :services, through: :provider_services

  has_many :provider_locations
  has_many :locations, through: :provider_locations

  has_many :bookings
  has_many :rates
  has_many :availabilities

end
