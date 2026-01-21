class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    room = Room.find(params[:room_id])

    unless room.users.include?(current_user)
      head :forbidden and return
    end

    room.messages.create!(
      context: params[:message][:context],
      user: current_user
    )
  end
end
