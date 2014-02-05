class MainPageController < ApplicationController
  def index
    puts params
    c = State.count
    @state = State.limit(1).offset(rand(c))[0]
  end
end
