class RateValidator < ActiveModel::Validator
  def validate(record)
    if record.start_time && record.end_time
      if record.start_time_minutes >= record.end_time_minutes
        record.errors[:base] << "Start time can't be after end time"
      end
      if record.service
        if record.service.min_length
          if record.service.min_length > record.length_minutes
            record.errors[:base] << 'Rate window must encompass minimum service booking'
          end
        end
        unless Rate.available?(record.service, record.day, record.start_time, record.end_time, record.id)
          record.errors[:base] << 'Requested time not available'
        end
      end
    end
  end
end

class Rate < ApplicationRecord
  validates_presence_of :day, :cost_amount, :cost_per, :start_time, :end_time, :service

  validates_with RateValidator

  belongs_to :service

  def start_time_minutes
    return nil unless self.start_time
    self.start_time.seconds_since_midnight / 60
  end

  def end_time_minutes
    return nil unless self.end_time
    self.end_time.seconds_since_midnight / 60
  end

  def length_minutes
    return nil unless self.start_time && self.end_time
    end_time_minutes - start_time_minutes
  end

  def day_name
    Date::DAYNAMES[day]
  end

  class << self

    def find_rate_at(service, day, time)
      search_time = time.seconds_since_midnight / 60
      Rate.where({service: service, day: day}).order(:start_time).each do |rate|
        if search_time >= rate.start_time_minutes && search_time < rate.end_time_minutes
          return rate
        end
      end
      nil
    end

    def available?(service, day, time_from, time_to, ignore_id = nil)
      search_start = time_from.seconds_since_midnight / 60
      search_end = time_to.seconds_since_midnight / 60
      Rate.where({service: service, day: day}).order(:start_time).each do |rate|
        unless ignore_id && ignore_id == rate.id
          return false if rate.start_time_minutes < search_end && rate.end_time_minutes > search_start
        end
      end
      true
    end

  end

end
