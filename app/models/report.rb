# == Schema Information
#
# Table name: reports
#
#  id         :bigint           not null, primary key
#  active     :boolean
#  link       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Report < ApplicationRecord
end
