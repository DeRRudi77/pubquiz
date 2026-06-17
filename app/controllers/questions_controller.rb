class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: %i[show edit update destroy]
  before_action :set_round, only: %i[create]

  # GET /questions
  def index
    @questions = Question.joins(round: :game).where(games: {user_id: current_user.id})
  end

  # GET /questions/1
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /rounds/:round_id/questions
  def create
    Rounds::AddQuestion.run!(round: @round)
    render turbo_stream: turbo_stream.replace(@round, partial: "rounds/form", locals: {round: @round.reload})
  end

  # PATCH/PUT /questions/1
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: "Question was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  def destroy
    round = @question.round
    @question.destroy
    render turbo_stream: turbo_stream.replace(round, partial: "rounds/form", locals: {round: round.reload})
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_question
    @question = Question.find(params[:id])
    require_game_owner!(@question.round.game)
  end

  def set_round
    @round = Round.find(params[:round_id])
    require_game_owner!(@round.game)
  end

  # Only allow a list of trusted parameters through.
  def question_params
    params.require(:question).permit(:question)
  end
end
