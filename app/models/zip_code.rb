class ZipCode < ActiveRecord::Base
  has_many :city_aliases, foreign_key: 'zip_code_id',primary_key: 'ZipCode'
  belongs_to :state
end
