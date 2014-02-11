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
    elsif [NearestDataType,RandomDataType].include?(type)
      render(json:shortDataSearch(data,type)) && return
    else
    render json:{} && return
    end
  end
end