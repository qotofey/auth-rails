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
        @user = User.new(user_params)

        if @user.save
          render json: @user, status: :created, location: @user
        else
          render json: @user.errors, status: :unprocessable_content
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
        params.expect(user: [ :name, :middle_name, :last_name, :birth_date, :gender, :blocked_at, :deleted_at ])
      end
    end
  end
end
