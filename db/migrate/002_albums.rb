class Albums < ActiveRecord::Migration
  def self.up
    create_table :albums do |table|
      table.column :albumName, :string
    end
  end

  def self.down
    drop_table :albums
  end
end
