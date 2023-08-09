module Integrations
  module V1
    class VouchersController < IntegrationsController
      def show
        voucher = current_integration.vouchers.find_by(external_id: params[:id])

        if voucher
          render json: VoucherBlueprint.render(voucher), status: :ok
        else
          render json: { error: I18n.t('vouchers.invalid_voucher') }, status: :not_found
        end
      end
    end
  end
end
