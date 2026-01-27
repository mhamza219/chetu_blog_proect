class LineItem < ApplicationRecord
  # We tell Rails to use the string columns for associations
  belongs_to :product, class_name: "Product", foreign_key: "product_id"
  belongs_to :cart, class_name: "Cart", foreign_key: "cart_id", optional: true
  belongs_to :order, class_name: "Order", foreign_key: "order_id", optional: true

  # Validations help us see errors in the console
  validates :product_id, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  def total_price
    product.present? ? (product.price * quantity) : 0
  end
end