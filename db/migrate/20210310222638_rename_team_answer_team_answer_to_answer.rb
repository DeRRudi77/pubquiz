class RenameTeamAnswerTeamAnswerToAnswer < ActiveRecord::Migration[6.1]
  def change
    rename_column :team_answers, :team_answer, :answer
  end
end
