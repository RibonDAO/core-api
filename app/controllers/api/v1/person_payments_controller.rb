module Api
  module V1
    class PersonPaymentsController < ApplicationController
      def index
        @person_payments = PersonPayment.where.not(payer_type: 'BigDonor').order(sortable).page(page).per(per)

        render json: PersonPaymentBlueprint.render(@person_payments, total_items:, page:, total_pages:)
      end

      def payments_for_receiver_by_person
        if valid_receiver_type?
          @person_payments = person_payments_for(receiver_type.camelize)
          view = receiver_type.to_sym

          render json: PersonPaymentBlueprint.render(@person_payments, total_items:, page:,
                                                                       total_pages:, view:)
        else
          head :unprocessable_entity
        end
      end

      def big_donors
        @person_payments = PersonPayment.where(payer_type: 'BigDonor').order(sortable).page(page).per(per)

        render json: PersonPaymentBlueprint.render(@person_payments, total_items:, page:,
                                                                     total_pages:, view: :big_donations)
      end

      private

      def person_payments_for(receiver_type)
        customer = Customer.find_by(email:)
        crypto_user = CryptoUser.find_by(wallet_address:)

        if customer.present? || crypto_user.present?
          PersonPayment.where(
            status: :paid,
            payer: [customer, crypto_user].compact,
            receiver_type:
          ).order(sortable).page(page).per(per)
        else
          PersonPayment.none
        end
      end

      def email
        return unless params[:email]

        Base64.strict_decode64(params[:email])
      end

      def wallet_address
        return unless params[:wallet_address]

        Base64.strict_decode64(params[:wallet_address])
      end

      def receiver_type
        params[:receiver_type]
      end

      def valid_receiver_type?
        %w[cause non_profit].include?(receiver_type)
      end

      def sortable
        @sortable ||= params[:sort].present? ? "#{params[:sort]} #{sort_direction}" : 'created_at desc'
      end

      def sort_direction
        %w[asc desc].include?(params[:sort_dir]) ? params[:sort_dir] : 'asc'
      end

      def total_pages
        @person_payments.page(@page).total_pages
      end

      def total_items
        @total_items = @person_payments.count
      end

      def page
        @page = params[:page] || 1
      end

      def per
        @per = params[:per] || 100
      end
    end
  end
end
