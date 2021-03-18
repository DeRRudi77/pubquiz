class TeamAnswersController < ApplicationController
  before_action :set_answer, only: [:update]

  # POST /answers
  # POST /answers.json
  def create
    @team = TeamAnswer.new(answer_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to team_path(id: @team.uuid), notice: "Answers successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@team_answer, partial: "answers/answer", locals: {team_answer: @team_answer}) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @team_answer = TeamAnswer.find(params[:id])
  end

  def team
    @team_answer.team
  end

  # Only allow a list of trusted parameters through.
  def answer_params
    params.require(:team_answer).permit(:answer_1, :answer_2, :answer_3, :answer_4, :answer_5, :answer_6, :answer_7, :answer_8, :answer_9, :answer_10)
  end
end
