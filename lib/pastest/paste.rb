class Paste
  include DataMapper::Resource

  property :id,   Serial
  property :body, String, :required => true

  def initialize(id, body)
    @id = id
    @body = body
  end
end