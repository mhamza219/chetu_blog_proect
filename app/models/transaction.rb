class Transaction < ApplicationRecord
  belongs_to :order
  
  validates :stripe_id, presence: true, uniqueness: true
end
