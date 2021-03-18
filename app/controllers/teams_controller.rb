class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :update]

  # GET /teams/1
  # GET /teams/1.json
  def show
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@team, partial: "teams/team", locals: {team: @team, notice: update_notice}) }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@team, partial: "teams/team", locals: {team: @team}) }
      end
    end
  end

  private

  def update_notice
    return "Answers saved" if params[:commit] == "Save answers"
    "Team name saved"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def team_params
    params.require(:team).permit(:name, team_answers_attributes: [:answer, :id])
  end
end
