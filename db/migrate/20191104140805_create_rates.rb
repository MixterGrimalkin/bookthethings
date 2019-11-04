class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates do |t|
      t.string :name
      t.integer :cost_amount
      t.string :cost_per
      t.integer :min_length
      t.integer :service_id
      t.integer :provider_id

      t.timestamps
    end
  end
end
