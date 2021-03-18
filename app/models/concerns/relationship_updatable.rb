module RelationshipUpdatable
  extend ActiveSupport::Concern

  def update_relationship_to_amount(relationship, amount)
    if relationship.none?
      amount.times do |number|
        relationship.create!(number: number + 1)
      end
    elsif amount < relationship.count
      relationship.last(relationship.count - amount).each(&:destroy!)
    elsif amount > relationship.count
      (amount - relationship.count).times do
        relationship.create!(number: (relationship.last.number + 1))
      end
    end
  end
end
