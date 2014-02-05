class Indexes < ActiveRecord::Migration
  def change
    add_index :city_aliases,:zip_code_id
    add_index :city_aliases, :City
    add_index :city_aliases, :CityAbbreviation
    #add_index :zip_codes, :County
    add_index :zip_codes, :Longitude
    add_index :zip_codes, :Latitude
    #add_index :zip_codes, :state_id
  end
end
