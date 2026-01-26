class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.string :user_id
      t.integer :total
      t.string :status
      t.string :stripe_checkout_id

      t.timestamps
    end
  end
end
