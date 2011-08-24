class Presentation
  include DataMapper::Resource
  
  property :id,           Serial
  property :title,        String, :length => 30
  property :style,        String, :length => 20
  property :transition,   String, :length => 20
  
  has n, :slides
end