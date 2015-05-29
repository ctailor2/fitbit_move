class HomepageController < ApplicationController
  respond_to :html, :json

  def index
    respond_to do |format|
      format.html {}
      format.json do
      end
    end
  end
end

