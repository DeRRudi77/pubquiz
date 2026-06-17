class TeamAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_answer, only: [:update]

  # PATCH/PUT /answers/1
  def update
    Games::ScoreAnswer.run!(team_answer: @team_answer, points: answer_params[:points])
    team = @team_answer.team
    round = @team_answer.round
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(@team_answer, partial: "team_answers/form", locals: {answer: @team_answer}),
          turbo_stream.update(
            "points_#{helpers.dom_id(round)}_#{helpers.dom_id(team)}",
            team.answers_for_round(round).sum(:points)
          )
        ]
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @team_answer = TeamAnswer.find(params[:id])
    require_game_owner!(@team_answer.game)
  end

  # Only allow a list of trusted parameters through.
  def answer_params
    params.require(:team_answer).permit(:points)
  end
end
