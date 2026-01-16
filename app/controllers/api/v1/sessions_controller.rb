class Api::V1::SessionsController < ApplicationController
  def index
  end

  def create
    render json: { status: :created }, status: :created
  end

  def update
    render json: { status: :updated }, status: :created
  end

  def delete
  end
end
