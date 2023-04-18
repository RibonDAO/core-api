module Service
  module Users
    class Statistics
      attr_reader :donations, :user, :customer

      def initialize(donations:, user:, customer:)
        @donations = donations
        @user = user
        @customer = customer
      end

      def total_causes
        causes_sql = "SELECT distinct cause_id FROM donations
               left outer join non_profits on non_profits.id = donations.non_profit_id
               left outer join causes on causes.id = non_profits.cause_id
               where donations.user_id = #{user.id}"
        causes = ActiveRecord::Base.connection.execute(causes_sql).to_a.map { |cause| cause['cause_id'] }
        causes += person_payment.where(receiver_type: 'Cause').map(&:receiver_id) if customer

        causes.uniq
      end

      def total_tickets
        donations.count
      end

      def total_non_profits
        total_non_profits = donations.distinct(:non_profit_id).map(&:non_profit_id)
        total_non_profits += person_payment.where(receiver_type: 'NonProfit').map(&:receiver_id) if customer
        total_non_profits.uniq
      end

      def total_donated
        person_payments_brl = person_payment.where(currency: 0).sum(:amount_cents) / 100
        person_payments_usd = person_payment.where(currency: 1).sum(:amount_cents) / 100

        { brl: (person_payments_brl + convert_to_brl(person_payments_usd)),
          usd: (person_payments_usd + convert_to_usd(person_payments_brl)) }
      end

      def statistics
        donated = total_donated if customer
        { total_non_profits: (total_non_profits || []).count,
          total_tickets: donations.count,
          total_donated: donated || 0,
          total_causes: (total_causes || []).count }
      end

      private

      def person_payment
        PersonPayment.where(payer: customer, status: :paid)
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
