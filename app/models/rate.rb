class Rate < ApplicationRecord
  validates_presence_of :name, :cost_amount, :cost_per

  belongs_to :provider
  belongs_to :service

  has_many :availability_rates
  has_many :availabilities, through: :availability_rates

end
