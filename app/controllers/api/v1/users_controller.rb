# frozen_string_literal: true

module Api
  module V1
    class Api::V1::UsersController < ApplicationController
      before_action :set_user, only: %i[show update destroy]

      def index
        @users = User.all

        render json: @users
      end

      def show
        render json: UserSerializer.new(@user).serializable_hash
      end

      def create
        # binding.irb
        user = User.new do |u|
          u.credentials_attributes = [ credential_params ]
          u.password_attributes = secret_params
        end
        if user.save
          render json: UserSerializer.new(user).serializable_hash, status: :created# , location: @user
        else
          render json: user.errors, status: :unprocessable_content
        end
      end

      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_content
        end
      end

      def destroy
        @user.destroy!
      end

      private

      def set_user
        @user = User.find(params.expect(:id))
      end

      def user_params
        params.from_jsonapi(:camel).require(:user).permit(%i[name middle_name last_name birth_date gender])
      end

      def credential_params
        params.from_jsonapi(:camel).require(:user).permit(%i[kind login])
      end

      def secret_params
        params.from_jsonapi(:camel).require(:user).permit(%i[password])
      end
    end
  end
end
