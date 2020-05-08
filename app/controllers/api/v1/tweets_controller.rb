module Api
  module V1
    class TweetsController < Api::V1::ApiController
      def index
      end

      def show
      end

      def create
      end

      def destroy
      end

      def update
      end

      private

      def set_tweet
        @tweet = Tweet.find(params[:id])
      end

      def tweet_params
        params.require(:tweet).permit(:body, :tweet_original_id)
      end
    end
  end
end
