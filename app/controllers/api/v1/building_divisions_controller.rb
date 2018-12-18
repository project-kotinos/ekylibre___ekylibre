module Api
  module V1
    class BuildingDivisionsController < Api::V1::BaseController
      def index
        @divisions = BuildingDivision.all
      end
    end
  end
end
