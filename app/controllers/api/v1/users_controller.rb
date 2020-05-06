module Api
  module V1
    class UsersController < Api::V1::ApiController
      before_action :authenticate_user, only: %i[current update destroy]
      before_action :set_user, only: %i[show destroy update following followers]
      before_action :set_page except: %i[follwers following create]

      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
      end

      def update
      end

      def current
      end

      def show
      end

      def following
      end

      def followers
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def set_user
        @user = User.find(params[:id])
      end

      def set_page
        @page = params['page'] || 1
      end
    end
  end
end
