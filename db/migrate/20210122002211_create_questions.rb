class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions, id: :uuid do |t|
      t.belongs_to :round, null: false, foreign_key: true, type: :uuid
      t.integer :number, null: false
      t.text :question
      t.text :answer

      t.timestamps
    end
  end
end
