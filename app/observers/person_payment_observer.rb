class PersonPaymentObserver < ActiveRecord::Observer
  def after_update(person_payment)
    if person_payment.previous_changes[:status] == %w[processing paid] &&
       person_payment.paid? &&
       person_payment.credit_card?
      Mailers::SendPersonPaymentEmailJob.perform_later(person_payment:)
    end
  rescue StandardError
    nil
  end
end
