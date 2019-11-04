class CreateProviderServices < ActiveRecord::Migration[5.1]
  def change
    create_table :provider_services do |t|
      t.integer :service_id
      t.integer :provider_id

      t.timestamps
    end
  end
end
