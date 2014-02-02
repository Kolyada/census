class CreateCityAliases < ActiveRecord::Migration
  def change
    create_table :city_aliases do |t|
      t.integer :zip_code_id, options: "AUTO INCREMENT"
      t.string  :City
      t.string  :CityAbbreviation
    end
  end
end
