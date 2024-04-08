module Managers
  module V1
    class ReportsController < ManagersController
      def index
        @reports = Report.all
        render json: ReportBlueprint.render(@reports)
      end

      def create
        @report = Report.new(report_params)

        if @report.save
          render json: ReportBlueprint.render(@report), status: :created
        else
          head :unprocessable_entity
        end
      end

      def show
        @report = Report.find(params[:id])
        render json: ReportBlueprint.render(@report)
      end

      def update
        @report = Report.find(params[:id])

        if @report.update(report_params)
          render json: ReportBlueprint.render(@report), status: :ok
        else
          head :unprocessable_entity
        end
      end

      def destroy
        @report = Report.find(params[:id])
        if @report.destroy
          head :no_content
        else
          head :unprocessable_entity
        end
      end

      private

      def report_params
        params.permit(:id, :name, :link, :active)
      end
    end
  end
end
