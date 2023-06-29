# == Schema Information
#
# Table name: email_logs
#
#  id                     :bigint           not null, primary key
#  email_type             :integer
#  receiver_type          :string           not null
#  sendgrid_template_name :string
#  status                 :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  receiver_id            :string           not null
#
require 'rails_helper'

RSpec.describe EmailLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
