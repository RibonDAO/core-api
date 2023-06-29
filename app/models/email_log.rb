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
class EmailLog < ApplicationRecord
  belongs_to :receiver, polymorphic: true

  enum email_type: {
    default: 0,
    patron_contribution: 1
  }

  enum status: {
    enqueued: 0,
    sent: 1
  }

  def self.email_already_sent?(receiver:, sendgrid_template_name:)
    EmailLog.exists?(receiver:, sendgrid_template_name:)
  end

  def self.log(sendgrid_template_name:, email_type:, receiver:)
    EmailLog.create(sendgrid_template_name:, email_type:, receiver:)
  end
end
