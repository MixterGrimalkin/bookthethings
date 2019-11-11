class RateValidator < ActiveModel::Validator
  def validate(record)
    if record.start_time && record.end_time
      if record.start_time_minutes >= record.end_time_minutes
        record.errors[:base] << "Start time can't be after end time"
      end
    end
    if record.service && record.service.min_length
      if record.service.min_length > record.length_minutes
        record.errors[:base] << 'Rate window must encompass minimum service booking'
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

end
