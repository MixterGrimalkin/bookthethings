class AddSessionContraintsToService < ActiveRecord::Migration[5.1]
  def up
    add_column :services, :booking_resolution, :integer, default: 60
    add_column :services, :min_length, :integer, default: nil
    add_column :services, :max_length, :integer, default: nil
  end
  def down
    remove_column :services, :booking_resolution, :integer
    remove_column :services, :min_length, :integer
    remove_column :services, :max_length, :integer
  end
end
