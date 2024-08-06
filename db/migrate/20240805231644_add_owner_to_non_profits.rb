class AddOwnerToNonProfits < ActiveRecord::Migration[7.0]
  def change
    add_reference :non_profits, :owner, polymorphic: true
  end
end
