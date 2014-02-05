module ApplicationHelper
  def loadRawData(file='db/result.csv')#with id
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
    CityAlias.delete_all
    sql='insert into city_aliases ("zip_code_id","City", "CityAbbreviation") select "ZipCode", "City", "CityAbbreviation" from loaded_data'
    ActiveRecord::Base.connection.execute(sql)
    createStates
    ZipCode.delete_all
    resultColumns = ZipCode.columns.map{|c| c.name}
    colToInsert = %Q["#{resultColumns.join('","')}"]
    colToSelect = colToInsert.dup
    colToSelect.sub!(%Q["state_id"],%Q[coalesce((select id from states s where trim(s."StateAbbreviation")=trim(d."StateAbbreviation") limit 1),0)])
    sql = %Q[insert into zip_codes (#{colToInsert}) select distinct #{colToSelect} from loaded_data d]
    ActiveRecord::Base.connection.execute(sql)
    EasyZip.delete_all
    sql='insert into easy_zips select "ZipCode","Latitude","Longitude","County", state_id from zip_codes'
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

  def createResponse(options=nil)
    options ||= Hash.new
    options[:status] ||= 'success'
    options
  end
end
