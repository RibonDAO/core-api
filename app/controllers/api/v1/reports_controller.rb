module Api
  module V1
    class ReportsController < ApplicationController
      def index
        @reports = Report.where(active: true).order(created_at: :ASC)
        render json: ReportBlueprint.render(@reports)
      end

      def show
        @report = Report.find(params[:id])
        render json: ReportBlueprint.render(@report)
      end

      private

      def report_params
        params.permit(:id, :active)
      end
    end
  end
end
