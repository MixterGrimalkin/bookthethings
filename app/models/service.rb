class Service < ApplicationRecord
  validates_presence_of :name

  has_many :bookings
  has_many :rates

  has_many :provider_services
  has_many :providers, through: :provider_services

  has_many :availability_services
  has_many :services, through: :availability_services

end
