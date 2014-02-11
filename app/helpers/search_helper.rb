module SearchHelper
  include ApplicationHelper
  def fullSearchByZip(zipdata)
    ziplist = zipdata.split('').select{|l| ((0..9).map{|d|d.to_s}<<'|').include?(l)}
              .join('').split('|').map{|x|x.to_i}.select{|d| (1..100000).include?(d)}
    return jsonResult(error:I18n.t("errors.emptyZipList")) if ziplist.empty?
    ziplist = ziplist[0,DataSearchLimit]
    cur = ZipCode.includes("state").includes("cbsa").includes("city_aliases").where(ZipCode:ziplist)
    output = jsonResult(data:serializeZips(cur))
    output[:notice] = I18n.t("messages.manyZips") if (ziplist.size>DataSearchLimit)
    output
  end

  def shortDataSearch(zipdata,type)
    zip = zipdata.to_i
    return jsonResult(error:I18n.t("errors.longZip")) unless likeAZip?(zip)
    sql = SqlShortSearch + %Q[where z."ZipCode"=#{zip}]
    cur = ActiveRecord::Base.connection.execute(sql)
    return jsonResult(error:I18n.t("errors.noZip")) unless cur.any?
    zipCode = cur[0]
    sql = ((type==RandomDataType) ? compareRandomSql(zipCode['ZipCode']) : compareNearestSql(zipCode['ZipCode']))
    cur = ActiveRecord::Base.connection.execute(sql)
    return jsonResult(error:I18n.t("errors.noCity")) unless cur.any?
    makeShortData(cur)
  end


  def shortSearchByZip(zipdata)
    result = {'CityAbbreviation'=>[]}
    zip = zipdata.to_i
    return jsonResult(error:I18n.t("errors.longZip")) unless likeAZip?(zip)
    sql = SqlShortSearch + %Q[where z."ZipCode"=#{zip}]
    cur = ActiveRecord::Base.connection.execute(sql)
    return jsonResult(error:I18n.t("errors.noZip")) unless cur.any?
    cur.each do |obj|
      obj.each_pair{|k,v| result[k]=v unless (k=='CityAbbreviation'  || v.blank?)}
      result['CityAbbreviation'] << obj['CityAbbreviation'] unless obj['CityAbbreviation'].blank?
      result['CityAbbreviation'].uniq!
    end
    jsonResult(status:'success',data:[result])
  end

  def shortSearchByCity(input)
    return jsonResult(error:I18n.t("errors.noParam")) if input.nil?
    data = allowCitySearchString(input)
    return  jsonResult(error:I18n.t("errors.zeroSize")) if data.blank?
    return jsonResult(error:I18n.t("errors.tooShort")) if data.size<3
    sql = SqlShortSearch +
        %Q[where z."County" like '%#{data}%' or c."CBSAName" like '%#{data}%' or a."City" like '%#{data}%' or a."CityAbbreviation" like '%#{data}%'
        order by z."ZipCode" limit #{DataSearchLimit}]
    cur = ActiveRecord::Base.connection.execute(sql)
    return jsonResult(error:I18n.t("errors.noCity")) unless cur.any?
    makeShortData(cur)
  end

  def allowCitySearchString(data)
    allowString = ('A'..'Z').map{|x|x}.join+('0'..'9').map{|x|x}.join+" #&'()-_./"
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
      record['cbsa'] = rec.cbsa.as_json if record.include?('cbsa')
      record
    end
    result
  end
end