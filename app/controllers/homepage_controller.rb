class HomepageController < ApplicationController
  respond_to :html, :json

  def index
    respond_to do |format|
      format.html {}
      format.json do
        render json: { step_count: current_user.step_count }.to_json
      end
    end
  end
end

