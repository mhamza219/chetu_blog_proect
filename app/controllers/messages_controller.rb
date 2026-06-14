class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @room = Room.find(params[:room_id])

    unless @room.users.include?(current_user)
      head :forbidden and return
    end

    @message = @room.messages.create!(
      context: params[:message][:context],
      user: current_user
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @room }
    end
  end

  def read
    @room = Room.find(params[:room_id])
    @message = @room.messages.find(params[:id])

    unless @room.users.include?(current_user)
      head :forbidden and return
    end

    if @message.user_id != current_user.id && !@message.read
      @message.update(read: true)
    end

    head :ok
  end
end
