class Customer < ApplicationRecord
  validates_presence_of :name, :email

  belongs_to :user

  has_many :bookings

  has_many :customer_registrations
  has_many :companies, through: :customer_registrations

  has_many :customer_locations
  has_many :locations, through: :customer_locations

  def registered_with?(company)
    companies.include? company
  end

  def register_with(company)
    companies << company
  end

end
