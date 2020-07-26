class RoomsController < ApplicationController
  before_action :set_room, only: %i[show edit update destroy]
  before_action :set_rooms, only: %i[index]
  before_action :global_occupancy_rate_calculation, only: %i[index]

  def index
  end

  def show
  end

  def new
    @room = Room.new
  end

  def edit
  end

  def create
    @room = Room.new(room_params)

    if @room.save
      redirect_to @room, notice: 'Room was successfully created.'
    else
      render :new
    end
  end

  def update
    if @room.update(room_params)
      redirect_to @room, notice: 'Room was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @room.destroy
      redirect_to rooms_url, notice: 'Room was successfully destroyed.'
    else
      redirect_to rooms_url, alert: "You can't remove a room that already has reservations."
    end
  end

  private
    def set_room
      @room = Room.find(params[:id])
    end

    def set_rooms
      @rooms = Room.all
    end

    def global_occupancy_rate_calculation
      number_of_rooms = @rooms.count.zero? ? 1 : @rooms.count

      @global_weekly_occupancy_rate = (@rooms.sum(&:weekly_occupancy_rate) / number_of_rooms)
      @global_monthly_occupancy_rate = (@rooms.sum(&:monthly_occupancy_rate) / number_of_rooms)
    end

    def room_params
      params.require(:room).permit(:code, :capacity, :notes)
    end
end
