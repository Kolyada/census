class CreateStates < ActiveRecord::Migration
  def change
    create_table :states,primary_key: 'id' do |t|
      t.string :StateFullName
      t.string :StateAbbreviation
    end
    add_index :states, :StateFullName
    add_index :states, :StateAbbreviation
  end
end
