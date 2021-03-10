class Question < ApplicationRecord
  belongs_to :round
  has_one :team, through: :round

  has_many :team_answers, dependent: :destroy do
    def for_team(team)
      find_or_create_by(team: team)
    end
  end

end

# == Schema Information
#
# Table name: questions
#
#  id         :uuid             not null, primary key
#  answer     :text
#  number     :integer          not null
#  question   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  round_id   :uuid             not null
#
# Indexes
#
#  index_questions_on_round_id  (round_id)
#
# Foreign Keys
#
#  fk_rails_...  (round_id => rounds.id)
#
