# == Schema Information
#
# Table name: ribon_configs
#
#  id                                        :bigint           not null, primary key
#  contribution_fee_percentage               :decimal(, )
#  default_ticket_value                      :decimal(, )
#  disable_labeling                          :boolean          default(FALSE)
#  minimum_contribution_chargeable_fee_cents :integer
#  minimum_version_required                  :string           default("0.0.0")
#  ribon_club_fee_percentage                 :decimal(, )
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  default_chain_id                          :integer
#
FactoryBot.define do
  factory :ribon_config do
    default_ticket_value { 100 }
    default_chain_id { 0x13881 }
    contribution_fee_percentage { 20.0 }
    minimum_contribution_chargeable_fee_cents { 10 }
    ribon_club_fee_percentage { 15.0 }
  end
end
