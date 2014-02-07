class SearchController < ApplicationController
include SearchHelper

  def index
    data = params[:data]
    type=params[:type]
    if type==ShortDataType
      if likeAZip?(data)
        render(json:shortSearchByZip(data)) && return
      else
        render(json:shortSearchByCity(data)) && return
      end
    else
    render json:nothing
    end
  end
end