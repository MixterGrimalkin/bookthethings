class AddColorToService < ActiveRecord::Migration[5.1]
  def up
    add_column :services, :color, :string, default: 'blue'
  end
  def down
    remove_column :services, :color, :string
  end
end
