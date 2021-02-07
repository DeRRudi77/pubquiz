class RoundsController < ApplicationController
  before_action :set_round, only: [:show, :edit, :update, :destroy]


  # GET /rounds/1/edit
  def edit
  end

  # PATCH/PUT /rounds/1
  # PATCH/PUT /rounds/1.json
  def update
    respond_to do |format|
      if @round.update(round_params)
        if @round.next_round.present?
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@round, partial: 'rounds/form', locals: { round: @round.next_round }) }
        else
          format.html { redirect_to @round.game, notice: 'You are now ready to start your game.', status: 303 }
        end
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /rounds/1
  # DELETE /rounds/1.json
  def destroy
    @round.destroy
    respond_to do |format|
      format.html { redirect_to rounds_url, notice: 'Round was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_round
    @round = Round.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def round_params
    params.require(:round).permit(:number_of_questions)
  end
end
