class Movie < ActiveRecord::Base
  
  def self.get_ratings
    return ['G','R','PG-13','PG']
  end
    
end
