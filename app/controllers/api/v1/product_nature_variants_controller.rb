module Api
  module V1
    class ProductNatureVariantsController < Api::V1::BaseController
      def index
        @variants = ProductNatureVariant.all
      end
    end
  end
end
