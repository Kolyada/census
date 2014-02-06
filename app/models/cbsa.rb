class Cbsa < ActiveRecord::Base
  has_many :zip_codes,foreign_key: "cbsa_id",primary_key: "CBSA"
end
