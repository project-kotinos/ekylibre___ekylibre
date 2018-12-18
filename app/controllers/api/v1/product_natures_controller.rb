module Api
  module V1
    class ProductNaturesController < Api::V1::BaseController
      def index
        @natures = ProductNature.all
      end
    end
  end
end
