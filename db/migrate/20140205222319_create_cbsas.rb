class CreateCbsas < ActiveRecord::Migration
  def change
    create_table :cbsas,primary_key: "CBSA" do |t|
      t.string  :CBSAName
      t.integer :CBSADivision
      t.string  :CBSAStatisticType
    end
    add_index :cbsas, :CBSAName
  end
end
