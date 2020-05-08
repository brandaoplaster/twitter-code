module Api
  module V1
    class TweetsController < Api::V1::ApiController
      def index
      end

      def show
        render json: @tweetm include: '**'
      end

      def create
        @tweet = Tweet.new(tweet_params.merge(user: current_user))

        if @tweet.save
          render json: @tweet, status: :created
        else
          render json: { errors: @tweet.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @tweet.destroy
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
