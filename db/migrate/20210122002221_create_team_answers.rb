class CreateTeamAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :team_answers, id: :uuid do |t|
      t.belongs_to :question, null: false, foreign_key: true, type: :uuid
      t.belongs_to :team, null: false, foreign_key: true, type: :uuid
      t.text :team_answer
      t.integer :status, default: 0
      t.integer :points

      t.timestamps
    end

    add_index :team_answers, [:question_id, :team_id], unique: true
  end
end