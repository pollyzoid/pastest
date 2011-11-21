class Paste
  include DataMapper::Resource

  property :id,   Serial
  property :body, String, :required => true
end