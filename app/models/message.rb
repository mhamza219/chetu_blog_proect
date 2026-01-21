class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room

  after_create_commit -> {
    broadcast_append_to room,
      target: "messages",
      partial: "messages/message",
      locals: { message: self }
  }
end
