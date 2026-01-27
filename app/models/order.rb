class Order < ApplicationRecord
  belongs_to :user, foreign_key: :user_id
  has_many :line_items, foreign_key: :order_id, dependent: :destroy
  has_many :transactions, foreign_key: :order_id, dependent: :destroy
end