module Service
  module CryptoUsers
    class Statistics
      attr_reader :wallet_address

      def initialize(wallet_address:)
        @wallet_address = wallet_address
      end

      def total_causes
        person_payment.where(receiver_type: 'Cause').map(&:receiver_id).uniq
      end

      def total_non_profits
        person_payment.where(receiver_type: 'NonProfit').map(&:receiver_id).uniq
      end

      def total_donated
        person_payments_brl = person_payment.where(currency: 0).sum(:amount_cents) / 100
        person_payments_usd = person_payment.where(currency: 1).sum(:amount_cents) / 100

        { brl: (person_payments_brl + convert_to_brl(person_payments_usd)),
          usd: (person_payments_usd + convert_to_usd(person_payments_brl)) }
      end

      def statistics
        { total_non_profits: total_non_profits.count,
          total_tickets: 0,
          total_donated:,
          total_causes: total_causes.count }
      end

      private

      def person_payment
        PersonPayment.where(payer: crypto_user)
      end

      def crypto_user
        CryptoUser.find_by(wallet_address:)
      end

      def convert_to_usd(value)
        Currency::Converters.convert_to_usd(value:, from: 'BRL').to_f
      end

      def convert_to_brl(value)
        Currency::Converters.convert_to_brl(value:, from: 'USD').to_f
      end
    end
  end
end
