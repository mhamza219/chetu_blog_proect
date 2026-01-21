class RoomsController < ApplicationController

  # def create_private_room
  #   # byebug
  #   @user = User.find(params[:user_id])
  #   room_name = [current_user.id, @user.id].sort.join('_')
  #   @room = Room.find_or_create_by(name: "private_#{room_name}", is_group: false)
  #   @room.user << current_user unless @room.users.include?(current_user)
  #   @room.user << @user unless @room.users.include?(@user)

  #   redirect_to @room
  # end

  before_action :authenticate_user!

  def index
    @rooms = current_user.rooms
  end

  def new
    @users = User.where.not(id: current_user.id)
    @room = Room.new
  end

  def show
    @room = Room.find(params[:id])

    unless @room.users.include?(current_user)
      redirect_to rooms_path, alert: "Access denied"
      return
    end

    @messages = @room.messages.includes(:user).order(:created_at)
  end

  def create
    if params[:user_id].present?
      # 1-to-1 chat
      room = find_or_create_one_to_one_room(params[:user_id])
      redirect_to room
    else
      # Group chat
      room = Room.create!(
        name: params[:room][:name],
        is_group: true
      )

      user_ids = params[:room][:user_ids].reject(&:blank?)
      user_ids << current_user.id

      user_ids.uniq.each do |id|
        Participant.create!(room: room, user_id: id)
      end

      redirect_to room
    end
  end

  private

  def find_or_create_one_to_one_room(other_user_id)
    Room
      .joins(:participants)
      .where(is_group: false)
      .group("rooms.id")
      .having("COUNT(participants.user_id) = 2")
      .where(participants: { user_id: [current_user.id, other_user_id] })
      .first || create_one_to_one_room(other_user_id)
  end

  def create_one_to_one_room(other_user_id)
    room = Room.create!(is_group: false)
    Participant.create!(room: room, user: current_user)
    Participant.create!(room: room, user_id: other_user_id)
    room
  end
end