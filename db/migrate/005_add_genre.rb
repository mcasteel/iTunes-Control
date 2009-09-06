class AddGenre < ActiveRecord::Migration
  def self.up
    create_table :genres do |table|
      table.column :genreName, :string
    end
  end

  def self.down
    drop_table :genres
  end
end
