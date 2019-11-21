class DropAvailabilities < ActiveRecord::Migration[5.1]
  def change
    drop_table :availability_locations
    drop_table :availability_rates
    drop_table :availability_services
    drop_table :availabilities
  end
end
