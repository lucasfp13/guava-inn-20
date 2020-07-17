class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::DeleteRestrictionError do |exception|
    redirect_to rooms_url, alert:
      "You can't remove a room that already has reservations."
  end
end
