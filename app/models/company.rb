class Company < ApplicationRecord
  validates_presence_of :name, :slug

  has_many :providers

  has_many :customer_registrations
  has_many :customers, through: :customer_registrations
end
