module RoomBuilder
    def build_room(args = {})
      build(:room, args)
    end
  
    def create_room(args = {})
      create(:room, args)
    end
  end