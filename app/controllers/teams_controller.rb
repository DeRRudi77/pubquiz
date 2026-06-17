class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :update]

  # GET /teams/1
  def show
    @captain = captain?
  end

  # PATCH/PUT /teams/1
  def update
    return head :forbidden if team_params.key?(:name) && !captain?

    respond_to do |format|
      if @team.update(team_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@team, partial: "teams/team", locals: {team: @team, captain: captain?, notice: update_notice}) }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@team, partial: "teams/team", locals: {team: @team, captain: captain?}) }
      end
    end
  end

  private

  def update_notice
    return "Answers saved" if params[:commit] == "Save answers"
    "Team name saved"
  end

  # The current session's player is this team's captain.
  def captain?
    player = Player.find_or_create_by!(session_id: session.id, game_id: @team.game_id)
    player.team_captain && player.team_id == @team.id
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
