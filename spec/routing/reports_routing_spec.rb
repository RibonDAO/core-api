require "rails_helper"

RSpec.describe ReportsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/reports").to route_to("reports#index")
    end

    it "routes to #show" do
      expect(get: "/reports/1").to route_to("reports#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/reports").to route_to("reports#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/reports/1").to route_to("reports#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/reports/1").to route_to("reports#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/reports/1").to route_to("reports#destroy", id: "1")
    end
  end
end
