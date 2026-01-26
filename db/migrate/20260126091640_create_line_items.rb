class CreateLineItems < ActiveRecord::Migration[7.2]
  def change
    create_table :line_items do |t|
      t.string :product_id
      t.string :cart_id
      t.integer :quantity

      t.timestamps
    end
  end
end
