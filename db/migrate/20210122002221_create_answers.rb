class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers, id: :uuid do |t|
      t.belongs_to :round, null: false, foreign_key: true, type: :uuid
      t.belongs_to :team, null: false, foreign_key: true, type: :uuid
      t.text :answer_1
      t.text :answer_2
      t.text :answer_3
      t.text :answer_4
      t.text :answer_5
      t.text :answer_6
      t.text :answer_7
      t.text :answer_8
      t.text :answer_9
      t.text :answer_10

      t.timestamps
    end
  end
end