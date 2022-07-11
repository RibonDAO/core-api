class CreatePerson < ActiveRecord::Migration[7.0]
  def change
    create_table :people, id: :uuid
  end
end
