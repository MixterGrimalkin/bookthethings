class ServiceValidator < ActiveModel::Validator
  def validate(record)
    ensure_not_negative(record, :min_length)
    ensure_not_negative(record, :max_length)
    if record.min_length && record.max_length
      if record.max_length < record.min_length
        record.errors[:base] << "Length range can't be negative"
      end
      if record.booking_resolution
        if (record.max_length - record.min_length) % record.booking_resolution != 0
          record.errors[:base] << 'Length must be a multiple of resolution'
        end
      end
    end
  end
  def ensure_not_negative(record, field)
    value = record.send(field)
    if value && value <= 0
      record.errors[:base] << "#{field.to_sym} must be greater than 0"
    end
  end
end

class Service < ApplicationRecord
  validates_presence_of :name
  validates_with ServiceValidator

  has_many :bookings
  has_many :rates

  has_many :provider_services
  has_many :providers, through: :provider_services

  has_many :availability_services
  has_many :availabilities, through: :availability_services

end

