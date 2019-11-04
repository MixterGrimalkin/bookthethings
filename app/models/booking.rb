class Booking < ApplicationRecord
  validates_presence_of :start_date, :end_date
  belongs_to :service
  belongs_to :provider
  belongs_to :customer
  belongs_to :location
end
