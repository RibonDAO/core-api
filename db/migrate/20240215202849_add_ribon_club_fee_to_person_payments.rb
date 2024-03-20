class AddRibonClubFeeToPersonPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :person_payments, :ribon_club_fee_cents, :integer
  end
end
