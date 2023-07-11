module Managers
  module V1
    class PersonPaymentsController < ManagersController
      def index
        @person_payments = filtered_person_payments

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

      def big_donor_donation
        @person_payment = PersonPayment.find(params[:id])

        render json: PersonPaymentBlueprint.render(@person_payment, view: :big_donations)
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
        @person_payments.page(@page).per(per).total_pages
      end

      def total_items
        @total_items ||= @person_payments&.total_count
      end

      def page
        @page ||= query_params&.fetch('page', 1)
      end

      def per
        @per ||= query_params&.fetch('per_page', 10)
      end

      def query_params
        return unless request.query_parameters[:params]

        query_params = request.query_parameters[:params]
        JSON.parse(query_params)
      end

      def search_params
        @search_params = query_params&.fetch('search_term', '')
      end

      def email_or_wallet_address(search_params)
        customer_results = Customer.where('email ILIKE ?', "%#{search_params}%").pluck(:id)
        crypto_user_results = CryptoUser.where('wallet_address ILIKE ?', "%#{search_params}%").pluck(:id)

        users = customer_results + crypto_user_results

        PersonPayment.where(payer_id: users).order(sortable).page(page).per(per)
      end

      def filtered_person_payments
        if search_params.present?
          email_or_wallet_address(search_params)
        else
          PersonPayment.where.not(payer_type: 'BigDonor').order(sortable).page(page).per(per)
        end
      end
    end
  end
end
