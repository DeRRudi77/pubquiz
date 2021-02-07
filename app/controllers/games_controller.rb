class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy, :next_round]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.turbo_stream { render turbo_stream: turbo_stream.replace('game_wizard', partial: 'games/game_wizard', locals: { game: @game }) }
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace('game_wizard', partial: 'games/form', locals: { game: @game }) }
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace('game_wizard', partial: 'games/game_wizard', locals: { game: @game }) }
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@game, partial: 'games/form', locals: { game: @game }) }
        format.html { render :edit }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def next_round
    notice = @game.started? ? 'Game started' : 'Next round started'
    @game.next_round!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'game_wizard',
          partial: 'games/started',
          locals: { game: @game, notice: notice }
        )
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def game_params
      params.require(:game).permit(:name, :number_of_rounds, :number_of_teams, :current_round_number)
    end
end
