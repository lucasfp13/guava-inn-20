require 'helpers/room_builder'
require 'helpers/reservation_builder'

RSpec.configure do |config|
  config.include RoomBuilder
  config.include ReservationBuilder
end