class TeamAnswer < ApplicationRecord
  belongs_to :round
  belongs_to :team

  enum status: %i[pending correct incorrect], _default: "pending"
end

# == Schema Information
#
# Table name: team_answers
#
#  id          :uuid             not null, primary key
#  points      :integer
#  status      :integer          default("pending")
#  team_answer :text
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
