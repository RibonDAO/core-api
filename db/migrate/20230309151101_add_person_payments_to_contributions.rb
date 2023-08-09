class AddPersonPaymentsToContributions < ActiveRecord::Migration[7.0]
  def change
    add_reference :contributions, :person_payment, null: false, foreign_key: true
  end
end
