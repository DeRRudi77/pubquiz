class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update, :destroy, :edit, :start, :next_round, :show_results, :process_results, :join]
  before_action :authenticate_user!, except: [:join]

  # GET /games
  def index
    @games = Game.all.order(created_at: :desc)
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
  end

  # POST /games
  def create
    @game = Game.new(game_params)

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

  def start
    @game.start!
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
    @game.next_round!
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
    @game.process_results!
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
    @game.show_results!
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
  end

  def round_param
    params.permit(:round_id)
  end

  def game_params
    params.require(:game).permit(:name, :number_of_rounds, :number_of_teams, :current_round_number)
  end
end
