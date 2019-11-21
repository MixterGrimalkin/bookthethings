class Provider < ApplicationRecord
  validates_presence_of :company

  belongs_to :company
  belongs_to :user

  has_many :provider_services
  has_many :services, through: :provider_services

  has_many :provider_locations
  has_many :locations, through: :provider_locations

  has_many :bookings

end
