class ChangeAnswerPointsToFloat < ActiveRecord::Migration[6.1]
  def change
    change_column :team_answers, :points, :float
  end
end
