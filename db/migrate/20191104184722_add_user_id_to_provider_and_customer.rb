class AddUserIdToProviderAndCustomer < ActiveRecord::Migration[5.1]
  def up
    remove_column :providers, :email, :string
    remove_column :providers, :name, :string
    remove_column :providers, :phone, :string
    remove_column :customers, :email, :string
    remove_column :customers, :name, :string
    remove_column :customers, :phone, :string
    add_column :providers, :user_id, :integer
    add_column :customers, :user_id, :integer
    add_column :users, :phone, :string
  end
  def down
    add_column :providers, :email, :string
    add_column :providers, :name, :string
    add_column :providers, :phone, :string
    add_column :customers, :email, :string
    add_column :customers, :name, :string
    add_column :customers, :phone, :string
    remove_column :providers, :user_id, :integer
    remove_column :customers, :user_id, :integer
    remove_column :users, :phone, :string
  end
end
