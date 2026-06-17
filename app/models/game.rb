class Game < ApplicationRecord
  include RelationshipUpdatable

  belongs_to :user, optional: true

  has_many :rounds, -> { order(:number) }, dependent: :destroy
  has_many :teams, -> { order(:number) }, dependent: :destroy

  has_one :first_round, -> { where(number: 1) }, class_name: "Round"
  has_one :current_round, ->(game) { where(number: game.current_round_number) }, class_name: "Round"
  has_one :next_round, ->(game) { where(number: game.current_round_number + 1) }, class_name: "Round"
  has_many :visible_rounds,
    -> { where(status: [statuses[:started], statuses[:finished], statuses[:scored]]).order(:number) },
    class_name: "Round"
  enum :status, %i[pending_start started pending_results finished], default: "pending_start"

  validates :number_of_rounds, presence: true
  validates :name, presence: true

  after_save :update_rounds_and_teams

  broadcasts

  def reset!
    update(current_round_number: 0, status: :pending_start)
    rounds.update_all(status: :pending_start)
    teams.reload.each { |team| team.reload.broadcast_replace_to team }
  end

  def progress
    return 0 if number_of_rounds.to_i.zero?
    100 / number_of_rounds
  end

  def results
    teams.reorder(total_points: :desc).each_with_object({}) do |team, map|
      map[team.total_points].present? ? map[team.total_points] << team : map[team.total_points] = [team]
    end
  end

  # Public so interactions (e.g. Games::StartGame) can trigger a team reload.
  def broadcast_reload_teams
    teams.reload.each { |team| team.reload.broadcast_replace_to team }
  end

  private

  def update_rounds_and_teams
    update_relationship_to_amount(rounds, number_of_rounds)
    update_relationship_to_amount(teams, number_of_teams)
  end
end

# == Schema Information
#
# Table name: games
#
#  id                   :uuid             not null, primary key
#  current_round_number :integer          default(0)
#  name                 :string
#  number_of_rounds     :integer          default(3)
#  number_of_teams      :integer          default(2)
#  status               :integer          default("pending_start")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :uuid
#
# Indexes
#
#  index_games_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
