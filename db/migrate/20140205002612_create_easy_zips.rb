class CreateEasyZips < ActiveRecord::Migration
  def change
    create_table :easy_zips,primary_key: 'ZipCode' do |t|
      t.float   :Longitude
      t.float   :Latitude
      t.string  :County
      t.belongs_to :state
    end
    add_index :easy_zips, :Latitude
    add_index :easy_zips, :Longitude
    add_index :easy_zips, :County
    add_index :easy_zips, :state_id
  end
end
