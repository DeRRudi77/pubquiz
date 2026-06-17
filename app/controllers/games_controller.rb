class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:join]
  before_action :set_game, only: [:show, :update, :destroy, :edit, :setup_teams, :start, :next_round, :show_results, :process_results]
  before_action :set_joinable_game, only: [:join]

  # GET /games
  def index
    @games = current_user.games.order(created_at: :desc)
  end

  # GET /games/1
  def show
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  def edit
  end

  def join
    @player = Player.find_or_create_by!(session_id: session.id, game_id: @game.id)
  end

  # POST /games
  def create
    @game = current_user.games.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to edit_game_path(@game, step: 2), status: 303 }
        # format.turbo_stream { render turbo_stream: turbo_stream.replace("game_wizard", partial: "games/game_wizard", locals: {game: @game}) }
        # format.html { redirect_to @game, notice: "Game was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("game_wizard", partial: "games/form", locals: {game: @game}) }
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /games/1
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace("game_wizard", partial: "games/game_wizard", locals: {game: @game}) }
        format.html { redirect_to @game, notice: "Game was successfully updated." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@game, partial: "games/form", locals: {game: @game}) }
        format.html { render :edit }
      end
    end
  end

  # DELETE /games/1
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: "Game was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def setup_teams
    Games::SetupTeams.run!(game: @game)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "game_wizard",
          partial: "games/game",
          locals: {game: @game, notice: "Teams are being set up"}
        )
      end
    end
  end

  def start
    Games::StartGame.run!(game: @game)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "game_wizard",
          partial: "games/game",
          locals: {game: @game, notice: "Game started"}
        )
      end
    end
  end

  def next_round
    Games::AdvanceRound.run!(game: @game)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "game_wizard",
          partial: "games/game",
          locals: {game: @game, notice: "Next round started"}
        )
      end
    end
  end

  def process_results
    Games::ProcessResults.run!(game: @game)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "game_wizard",
          partial: "games/game",
          locals: {game: @game, notice: "Participants are now waiting for the results"}
        )
      end
    end
  end

  def show_results
    Games::ShowResults.run!(game: @game)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "game_wizard",
          partial: "games/game",
          locals: {game: @game, notice: "Game finished"}
        )
      end
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
    require_game_owner!(@game)
  end

  # `join` is the only unauthenticated entry point, so it can't scope by owner.
  def set_joinable_game
    @game = Game.find(params[:id])
  end

  def round_param
    params.permit(:round_id)
  end

  def game_params
    params.require(:game).permit(:name, :number_of_rounds, :number_of_teams, :current_round_number)
  end
end
