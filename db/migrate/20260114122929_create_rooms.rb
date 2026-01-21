class CreateRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :is_group, default: false

      t.timestamps
    end
  end
end
