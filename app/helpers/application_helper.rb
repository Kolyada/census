module ApplicationHelper
  def loadRawData()#with id
    loadData
    loadAliases
    createStates
    createCBSA
    loadZip
  end

  def loadData(file='db/result.csv')
    LoadedData.delete_all
    sql,counter = '',0
    open(file) do |f|
      f.readlines.each do |line|
        sql << "Insert into loaded_data values (#{line.split(';').map{|v| "'#{v.gsub("'","''").chomp}'"}.join(",")});"
        counter+=1
        if counter%100==0
          ActiveRecord::Base.connection.execute(sql)
          sql=''
        end
      end
    end
    ActiveRecord::Base.connection.execute(sql)
  end

  def loadAliases
    CityAlias.delete_all
    sql='insert into city_aliases ("zip_code_id","City", "CityAbbreviation") select "ZipCode", "City", "CityAbbreviation" from loaded_data'
    ActiveRecord::Base.connection.execute(sql)
  end

  def createStates(file='db/states.txt')
    return "#{file} not exists!!!" unless File.exist?(file)
    State.delete_all
    data = open(file){|f|f.readlines()}
    hash = data.map{|d| d.split("\t").map{|x|x.strip}}
    hash.each do |i, s,a|
      State.create id:i, StateFullName:s,StateAbbreviation:a
    end
  end

  def createCBSA(file='db/cbsa.txt')
    return "#{file} not exists!!!" unless File.exist?(file)
    Cbsa.delete_all
    data=open(file){|f| f.readlines()}
    arr = data.map{|d| d.split(';').map{|x| x.strip}}
    arr.each do |a,b,c,d|
      Cbsa.create CBSA:a, CBSAName:b, CBSADivision:c, CBSAStatisticType:d
    end
  end

  def jsonResult(options)
    result = {errors:[],notices:[]}
    result[:data] = options[:data]
    result[:status] = options[:status] || 'error'
    result[:errors] << options[:error]  if options.include?(:error)
    result[:notices] << options[:notice] if options.include?(:notice)
    result
  end

  def makeRow(obj,row=nil)
    result = {}
    result['CityAbbreviation'] = row.nil? ? [] : row['CityAbbreviation']
    obj.each_pair{|k,v| result[k]=v unless (k=='CityAbbreviation'  || v.blank?)}
    result['CityAbbreviation'] << obj['CityAbbreviation'] unless obj['CityAbbreviation'].blank?
    result['CityAbbreviation'].uniq!
    result
  end

  def compactResult(input)
    output={}
    input.each_pair{|k,v| output[k]=v unless v.blank?}
    output
  end

  def createResponse(options=nil)
    options ||= Hash.new
    options[:status] ||= 'success'
    options
  end

  def loadZip
    ZipCode.delete_all
    resultColumns = ZipCode.columns.map{|c| c.name}
    colToInsert = %Q["#{resultColumns.join('","')}"]
    colToSelect = colToInsert.dup
    colToSelect.sub!(%Q["state_id"],%Q[coalesce((select id from states s where trim(s."StateAbbreviation")=trim(d."StateAbbreviation") limit 1),0)])
    colToSelect.sub!(%Q["cbsa_id"],%Q[case d."CBSA" when '' then 0 else cast(d."CBSA" as integer) end])
    sql = %Q[insert into zip_codes (#{colToInsert}) select distinct #{colToSelect} from loaded_data d]
    ActiveRecord::Base.connection.execute(sql)
  end
end

