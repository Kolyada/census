class State < ActiveRecord::Base
  has_many :zip_codes
  has_many :easy_zips
end
