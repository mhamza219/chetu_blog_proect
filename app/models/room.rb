class Room < ApplicationRecord

  has_many :messages
  has_many :participants
  has_many :users, through: :participants

  has_one :last_message,
          -> { order(created_at: :desc) },
          class_name: "Message"

  def chat_title(current_user)
    if is_group?
      name
    else
      other_user = users.where.not(id: current_user.id).first
      other_user ? other_user.email.split('@').first.capitalize : "Private Chat"
    end
  end

  def last_message_text
    last_message&.context&.truncate(30) || "No messages yet"
  end

  def last_message_time
    last_message&.created_at&.strftime("%H:%M") || ""
  end
end
