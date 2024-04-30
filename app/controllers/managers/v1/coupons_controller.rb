module Managers
  module V1
    class CouponsController < ManagersController
      def index
        @coupons = Coupon.all
        render json: CouponBlueprint.render(@coupons)
      end

      def show
        @coupon = Coupon.find(params[:id])
        render json: CouponBlueprint.render(@coupon)
      end

      def create
        @coupon = Coupon.new(coupon_params)

        if @coupon.save
          render json: CouponBlueprint.render(@coupon), status: :created
        else
          head :unprocessable_entity
        end
      end

      def update
        @coupon = Coupon.find(params[:id])

        if @coupon.update(coupon_params)

          render json: CouponBlueprint.render(@coupon), status: :ok
        else
          head :unprocessable_entity
        end
      end

      def coupon_params
        params.permit(:id, :available_quantity, :expiration_date, :number_of_tickets, :reward_text, :status)
      end
    end
  end
end
