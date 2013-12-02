class IndexController < ApplicationController
  def index
    @shows = Show.all
  end
end