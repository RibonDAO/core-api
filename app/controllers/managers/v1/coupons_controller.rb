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
    end
  end
end
