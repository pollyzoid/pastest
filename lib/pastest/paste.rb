class Paste
  include DataMapper::Resource

  property :id,   Serial
  property :body, Text, :required => true
end