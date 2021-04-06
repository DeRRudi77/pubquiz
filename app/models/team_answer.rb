class TeamAnswer < ApplicationRecord
  belongs_to :question
  belongs_to :team

  has_one :round, through: :question
  has_one :game, through: :round

  enum status: %i[pending correct incorrect], _default: "pending"

  after_update :update_team_total_points

  private

  def update_team_total_points
    team.update_total_points!
  end
end

# == Schema Information
#
# Table name: team_answers
#
#  id          :uuid             not null, primary key
#  answer      :text
#  points      :float
#  status      :integer          default("pending")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :uuid             not null
#  team_id     :uuid             not null
#
# Indexes
#
#  index_team_answers_on_question_id              (question_id)
#  index_team_answers_on_question_id_and_team_id  (question_id,team_id) UNIQUE
#  index_team_answers_on_team_id                  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (team_id => teams.id)
#
