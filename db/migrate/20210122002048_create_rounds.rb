class CreateRounds < ActiveRecord::Migration[6.1]
  def change
    create_table :rounds, id: :uuid do |t|
      t.belongs_to :game, null: false, foreign_key: true, type: :uuid
      t.integer :number
      t.integer :number_of_questions
      t.integer :status

      t.timestamps
    end
  end
end
