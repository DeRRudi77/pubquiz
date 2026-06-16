class ApplicationController < ActionController::Base
  private

  # Halts the action unless the signed-in user owns the given game.
  # Responds 404 (not 403) so resource existence isn't leaked.
  def require_game_owner!(game)
    return if game && user_signed_in? && game.user_id == current_user.id

    if request.get?
      redirect_to root_path, alert: "Not authorized."
    else
      head :not_found
    end
  end
end
