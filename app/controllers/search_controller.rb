class SearchController < ApplicationController
include SearchHelper

  def index
    data = params[:data]
    type=params[:type]
    output = processSearch(data,type)
    if output.is_a?(String)
      result = createResponse(status:'error',errors:output)
    else
      result = createResponse(data:serializeZips(output),size:output.size)
      result['notice'] = I18n.t('messages.tooLong') if ((type==FullDataType && output.size==FullDataSearchLimit) || (output.size==DataSearchLimit))
    end
    render json:result
  end

end