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
        # form = RegistrationFrom.new({})
        # type_params
        user = User.new do |u|
          u.credentials_attributes = [ credential_params ]
          u.password_attributes = secret_params
        end
        if user.save
          render json: UserSerializer.new(user).serializable_hash, status: :created# , location: api_v1_user_url(@user)
        else
          render json: user.errors, status: :unprocessable_content
        end
      end

      def update
        if @user.update(user_params)
          render json: UserSerializer.new(@user).serializable_hash
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
        params.from_jsonapi(:camel).require(:user).permit(%i[name middle_name last_name birthday gender])
      end

      # def credential_params
      #   params.from_jsonapi(:camel).require(:user).permit(%i[login])
      # end

      def credential_params
        params.expect(data: [ attributes: [ :login, :kind ] ])
      end

      def secret_params
        params.from_jsonapi(:camel).require(:user).permit(%i[password])
      end

      def type_params
        params.expect(data: :type)
      end

      def registration_params
        params
          .deep_transform_keys!(&:underscore)
          .tap do
            attrs = it["data"]["attributes"]
            if attrs["username"]
              attrs.merge!(
                "kind" => "username",
                "login" => attrs["username"]
              )
              attrs.delete("username")
            end
          end
          .expect(
            data: [ attributes: %i[username password name middle_name last_name birthday gender] ]
          )
      end
    end
  end
end
