class Game < ApplicationRecord
  include RelationshipUpdatable

  has_many :rounds, -> { order(:number) }
  has_many :teams, -> { order(:number) }
  has_one :current_round, ->(game) { where(number: game.current_round_number) }, class_name: "Round"
  has_one :next_round, ->(game) { where(number: game.current_round_number + 1) }, class_name: "Round"
  has_many :started_and_finished_rounds,
    -> { where(status: [statuses[:started], statuses[:finished]]).order(:number) },
    class_name: "Round"
  enum status: %i[pending_start started pending_results finished], _default: "pending_start"

  validates :number_of_rounds, presence: true
  validates :name, presence: true

  after_save :update_rounds_and_teams

  broadcasts

  def start!
    started!
    rounds.first.started!
    update!(current_round_number: 1)
    # make sure all answer objects are ready
    rounds.each do |round|
      round.questions.each do |question|
        teams.each do |team|
          question.team_answers.for_team(team)
        end
      end
    end
    broadcast_reload_teams
  end

  def next_round!
    started! unless started?
    current_round.finished! if current_round.present?
    next_round.started!
    update!(current_round_number: (current_round_number + 1))
    broadcast_reload_teams
  end

  def process_results!
    pending_results! unless pending_results?
    broadcast_reload_teams
  end

  def show_results!
    finished! unless finished!
    broadcast_reload_teams
  end

  def reset!
    update(current_round_number: 0, status: :pending_start)
    rounds.update_all(status: :pending_start)
    teams.reload.each { |team| team.reload.broadcast_replace_to team }
  end

  def progress
    100 / number_of_rounds
  end

  private

  def broadcast_reload_teams
    teams.reload.each { |team| team.reload.broadcast_replace_to team }
  end

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
#  name                 :string
#  number_of_rounds     :integer          default(3)
#  number_of_teams      :integer          default(2)
#  current_round_number :integer          default(0)
#  status               :integer          default("pending_start")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
