# This class models the genres table and implements a caching scheme so that
# successive references to a genre don't require a database access.

class Genre < ActiveRecord::Base
  has_many :tracks
  has_many :albums
@@myGenre = nil
def self.create(*args)
  @@myGenre = super
end

def self.find_genre(name)
  if @@myGenre.nil? || @@myGenre.genreName != name 
    @@myGenre = self.find_by_genreName(name)
  end
  @@myGenre
end
end
