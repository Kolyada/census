class CityAlias < ActiveRecord::Base
  belongs_to :ZipCode, foreign_key: 'zip_code_id', primary_key: 'ZipCode'
  belongs_to :Easy_zip, foreign_key: 'zip_code_id', primary_key: 'ZipCode'
end
