class AddCauseReferencesToPool < ActiveRecord::Migration[7.0]
  def change
    add_reference :pools, :cause, foreign_key: true
  end
end
