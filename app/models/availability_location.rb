class AvailabilityLocation < ApplicationRecord
  belongs_to :availability
  belongs_to :location
end
