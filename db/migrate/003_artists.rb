class Artists < ActiveRecord::Migration
  def self.up
    create_table :artists do |table|
      table.column :artistName, :string
    end
  end

  def self.down
    drop_table :artists
  end
end
