class ZipCode < ActiveRecord::Base
  has_many :city_aliases
  belongs_to :state
end
