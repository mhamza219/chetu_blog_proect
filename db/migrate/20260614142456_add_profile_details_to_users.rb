class AddProfileDetailsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :display_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :address, :text
    add_column :users, :gender, :string
  end
end
