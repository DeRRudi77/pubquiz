class CreateRounds < ActiveRecord::Migration[6.1]
  def change
    create_table :rounds, id: :uuid do |t|
      t.belongs_to :game, null: false, foreign_key: true, type: :uuid
      t.integer :number, null: false
      t.integer :number_of_questions, default: 10
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
