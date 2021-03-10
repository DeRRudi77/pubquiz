class RemoveNumberOfQuestionsFromRound < ActiveRecord::Migration[6.1]
  def change
    remove_column :rounds, :number_of_questions
  end
end
