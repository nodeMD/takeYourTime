class Stoper < ActiveRecord::Base
  self.table_name = "stoppers"
  belongs_to :user

  def start
    self.running = true
    self.time = 0 if time.nil?
    save
  end

  def stop
    self.running = false
    save
  end

  def continue
    self.running = true
    save
  end

  def reset
    self.running = false
    self.time = 0
    save
  end

  def increment_time
    self.time += 100 if running? # Increment by 100ms
    save
  end

  def running?
    running
  end

  def time_in_seconds
    time / 1000.0
  end

  def time_in_minutes
    time_in_seconds / 60.0
  end

  def formatted_time
    total_seconds = time / 1000
    minutes = total_seconds / 60
    seconds = total_seconds % 60
    tenths = (time % 1000) / 100
    "#{minutes.to_i.to_s.rjust(2, "0")}:#{seconds.to_i.to_s.rjust(2, "0")}.#{tenths.to_i}"
  end
end
