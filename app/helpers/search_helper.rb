module SearchHelper
  include ApplicationHelper
  def allowSearchString(data)
    allowString = ('A'..'Z').map{|x|x}.join+('0'..'9').map{|x|x}.join+" #&'()-./"
    data.upcase.split('').select{|x| allowString.include?(x)}.join('').rstrip
  end

  def processSearch(input,type='normal')
    return I18n.t("errors.noParam") if input.nil?
    data = allowSearchString(input)
    return  I18n.t("errors.zeroSize") if data.blank?
    zip = data.to_i
    if zip>0
      if (1..100000).include?(zip)
        @zipcodes = searchByZip(zip)
        return (@zipcodes.count > 0) ? @zipcodes :  I18n.t("errors.noZip")
      else
        return I18n.t "errors.longZip"
      end
    else
      return I18n.t "errors.tooShort" if data.size<3
      @zipcodes = searchByCity(data,(type==FullDataType))
      return @zipcodes.any? ? @zipcodes : I18n.t("errors.noCity")
    end
  end

  def searchByZip(zip)
    result = ZipCode.includes("city_aliases").where(ZipCode:zip).limit(FullDataSearchLimit)
  end

  def searchByCity(data,fullData=false)
    (fullData ? ZipCode : EasyZip).includes('state').includes('city_aliases').where(%Q["City" like '%#{data}%' or "County" like '%#{data}%' or "CityAbbreviation" like '%#{data}%']).references('city_aliases')[1,((fullData) ? FullDataSearchLimit : DataSearchLimit) ] || []
  end

  def serializeZips(data)#data=[zip1,zip2,...,zipN]
    result = data.map do |rec|
      record = rec.as_json
      record['city_aliases'] = rec.city_aliases.as_json
      record['state'] = rec.state.as_json
      record
    end
    result
  end
end


