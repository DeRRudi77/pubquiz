class TeamAnswersController < ApplicationController
  before_action :set_answer, only: [:update]

  # PATCH/PUT /answers/1
  def update
    @team_answer.update(answer_params)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@team_answer, partial: "team_answers/form", locals: {answer: @team_answer}) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @team_answer = TeamAnswer.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def answer_params
    params.require(:team_answer).permit(:points)
  end
end
