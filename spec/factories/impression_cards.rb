# == Schema Information
#
# Table name: impression_cards
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(FALSE)
#  client      :string
#  cta_text    :string           default(""), not null
#  cta_url     :string           default(""), not null
#  description :string           default(""), not null
#  headline    :string           default(""), not null
#  title       :string           default(""), not null
#  video_url   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :impression_card do
    title { 'Doe R$ 10,00' }
    headline { 'CAMPANHA DE DIA DAS CRIANÇAS' }
    description { 'E ajude uma criança a viver seus primeiros 5 anos com saúde' }
    video_url { nil }
    cta_text { 'Doe agora' }
    cta_url { '/donate' }
  end
end
