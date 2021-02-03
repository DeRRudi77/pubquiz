class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :update]


  # GET /teams/1
  # GET /teams/1.json
  def show;  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@team, partial: 'teams/form', locals: { team: @team, notice: 'Team name successfully set' }) }
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@team, partial: 'teams/form', locals: { team: @team }) }
        format.html { render :show }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def team_params
    params.require(:team).permit(:name)
  end
end
