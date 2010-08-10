class TrogdorController < ApplicationController

  def burninate
    Resque.enqueue(Trogdor, params[:target])
    render :text => "Telling Trogdor to burninate #{params[:target]}."
  end

end
