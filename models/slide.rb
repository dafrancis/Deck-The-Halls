class Slide
  include DataMapper::Resource
  
  property :id,      Serial
  property :content, Text
  
  belongs_to :presentation, :key => true
end