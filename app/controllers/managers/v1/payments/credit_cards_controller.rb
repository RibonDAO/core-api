module Managers
  module V1
    module Payments
      class CreditCardsController < ManagersController
        include ::Givings::Payment

        def refund
          command = ::Givings::Payment::CreditCardRefund.call(external_id: params[:external_id])

          if command.success?
            head :created
          else
            render_errors(command.errors)
          end
        end
      end
    end
  end
end
