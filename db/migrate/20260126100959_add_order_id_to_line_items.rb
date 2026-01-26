class AddOrderIdToLineItems < ActiveRecord::Migration[7.2]
  def change
    add_column :line_items, :order_id, :string
  end
end
