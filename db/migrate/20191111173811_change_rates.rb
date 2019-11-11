class ChangeRates < ActiveRecord::Migration[5.1]
  def up
    remove_column :rates, :name, :string
    remove_column :rates, :cost_per, :string
    remove_column :rates, :min_length, :integer
    remove_column :rates, :provider_id, :integer
    add_column :rates, :cost_per, :integer
    add_column :rates, :day, :integer
    add_column :rates, :start_time, :time
    add_column :rates, :end_time, :time
  end
  def down
    add_column :rates, :name, :string
    add_column :rates, :cost_per, :string
    add_column :rates, :min_length, :integer
    add_column :rates, :provider_id, :integer
    remove_column :rates, :cost_per, :integer
    remove_column :rates, :day, :integer
    remove_column :rates, :start_time, :time
    remove_column :rates, :end_time, :time
  end
end
