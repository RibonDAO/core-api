class PersonPaymentObserver < ActiveRecord::Observer
  def after_update(person_payment)
    if person_payment.previous_changes[:status] == %w[processing paid] &&
       person_payment.paid? &&
       person_payment.credit_card? &&
       person_payment.subscription.nil?
      Mailers::SendPersonPaymentEmailJob.perform_later(person_payment:)
    end
    Events::Contributions::SendPersonPaymentEventJob.perform_later(person_payment:)
  rescue StandardError
    nil
  end
end
