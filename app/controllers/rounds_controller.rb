class RoundsController < ApplicationController
  before_action :set_round, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /rounds/1/edit
  def edit
  end

  # PATCH/PUT /rounds/1
  def update
    respond_to do |format|
      if @round.update(round_params)
        if params[:commit] == "Add question"
          @round.questions.create! number: @round.questions.last.number + 1

          format.turbo_stream { render turbo_stream: turbo_stream.replace(@round, partial: "rounds/form", locals: {round: @round.reload}) }
        elsif params[:commit] == "Remove question"
          @round.questions.last.destroy

          format.turbo_stream { render turbo_stream: turbo_stream.replace(@round, partial: "rounds/form", locals: {round: @round.reload}) }
        elsif @round.next_round.present?
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@round, partial: "rounds/form", locals: {round: @round.next_round}) }
        else
          format.html { redirect_to @round.game, notice: "You are now ready to start your game.", status: 303 }
        end
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@round, partial: "rounds/form", locals: {round: @round}) }
      end
    end
  end

  # DELETE /rounds/1
  def destroy
    @round.destroy
    respond_to do |format|
      format.html { redirect_to rounds_url, notice: "Round was successfully destroyed." }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_round
    @round = Round.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def round_params
    params.require(:round).permit(:commit, :title, :number_of_questions, questions_attributes: [:id, :question, :answer])
  end
end
