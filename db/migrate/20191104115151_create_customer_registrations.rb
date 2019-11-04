class CreateCustomerRegistrations < ActiveRecord::Migration[5.1]
  def change
    create_table :customer_registrations do |t|
      t.integer :company_id
      t.integer :customer_id

      t.timestamps
    end
  end
end
