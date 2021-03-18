class AdminsController < ApplicationController
  def index
    @game = Game.first
  end
end
