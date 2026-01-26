class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.string :order_id
      t.string :stripe_id
      t.integer :amount
      t.string :status
      t.string :last4
      t.string :card_brand

      t.timestamps
    end
  end
end
