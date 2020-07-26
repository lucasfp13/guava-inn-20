module ReservationBuilder
  def build_reservation(args = {})
    build(:reservation, args)
  end

  def create_reservation(args = {})
    create(:reservation, args)
  end
end