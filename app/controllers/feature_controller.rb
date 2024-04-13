class FeatureController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    begin
      render json: Feature.index(params[:mag_type], params[:per_page], params[:page])
    rescue => e
      render json: ["status" => "400", "message" => e, "data" => []]
    end
  end
  
  def get
    begin
      render json: Feature.get(params[:id])
    rescue => e
      render json: ["status" => "400", "message" => e, "data" => []]
    end
  end 
end
