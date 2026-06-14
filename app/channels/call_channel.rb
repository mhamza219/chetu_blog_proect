class CallChannel < ApplicationCable::Channel
  def subscribed
    stream_from "call_channel_user_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup when user disconnects
  end

  def send_signal(data)
    # Forward the WebRTC signal to the target user's stream
    target_user_id = data["to"]
    ActionCable.server.broadcast("call_channel_user_#{target_user_id}", {
      from: current_user.id,
      from_name: current_user.display_name.presence || current_user.email.split('@').first.capitalize,
      type: data["type"],
      payload: data["payload"]
    })
  end
end
