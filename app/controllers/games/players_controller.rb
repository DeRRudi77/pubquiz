module Games
  class PlayersController < ApplicationController
    before_action :set_player
    before_action :set_game

    # PATCH/PUT /players
    def update
      outcome = Games::UpdatePlayer.run(player: @player, name: player_params[:name])

      respond_to do |format|
        if outcome.valid?
          format.turbo_stream { render turbo_stream: turbo_stream.replace("player", partial: "players/player", locals: {player: @player, game: @game}, notice: "Name saved") }
          format.html { redirect_to join_game_path(@game), notice: "Name was successfully updated." }
        else
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@game, partial: "players/player", locals: {player: @player, game: @game}) }
          format.html { render template: "games/join", status: :unprocessable_entity }
        end
      end
    end

    def player_params
      params.require(:player).permit(:name)
    end

    def set_player
      @player = Player.find_or_create_by!(session_id: session.id, game_id: params[:game_id])
    end

    def set_game
      @game = Game.find(params[:game_id])
    end
  end
end
