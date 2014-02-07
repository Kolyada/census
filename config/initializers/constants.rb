FullDataType = 'fulldata'
ShortDataType = 'shortdata'
FullDataSearchLimit = 5
DataSearchLimit = 50
SqlShortSearch = %Q[select z."ZipCode", z."Longitude", z."Latitude", z."County"
  ,s."StateFullName",s."StateAbbreviation",c."CBSAName",c."CBSAStatisticType"
  ,a."City",a."CityAbbreviation"
  from zip_codes z
  join states s on s.id = z.state_id
  left join cbsas c on c."CBSA"=z.cbsa_id
  join city_aliases a on a.zip_code_id=z."ZipCode"]
