module Api
  module V1
    class ProductNatureCategoriesController < Api::V1::BaseController
      def index
        @categories = ProductNatureCategory.all
      end
    end
  end
end
