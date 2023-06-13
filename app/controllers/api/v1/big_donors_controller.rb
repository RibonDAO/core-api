module Api
  module V1
    class BigDonorsController < ApplicationController
      def index
        @big_donors = BigDonor.all

        render json: BigDonorBlueprint.render(@big_donors)
      end

      def create
        command = BigDonors::CreateBigDonor.call(big_donor_params)

        if command.success?
          render json: BigDonorBlueprint.render(command.result), status: :created
        else
          render_errors(command.errors)
        end
      end

      def show
        @big_donor = BigDonor.find(params[:id])

        render json: BigDonorBlueprint.render(@big_donor)
      end

      def update
        command = BigDonors::UpdateBigDonor.call(big_donor_params)

        if command.success?
          render json: BigDonorBlueprint.render(command.result), status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def big_donor_params
        params.permit(:id, :name, :email)
      end
    end
  end
end
