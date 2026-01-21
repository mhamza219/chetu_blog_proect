class Room < ApplicationRecord

  has_many :messages
  has_many :participants
  has_many :users, through: :participants

  
  has_one :last_message,
          -> { order(created_at: :desc) },
          class_name: "Message"
end
