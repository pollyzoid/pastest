require 'dm-core'
require 'dm-types'

# bleh
LANG_ENUM = []
LANGUAGES.each do |k, v|
  LANG_ENUM << k
end

class Paste
  include DataMapper::Resource

  property :id,         String,   :key => true, :default => lambda { |r, p| SecureRandom.urlsafe_base64 }
  property :created_at, DateTime
  property :updated_at, DateTime
  property :private,    Boolean,  :default => false
  property :body,       Text,     :required => true
  property :language,   Enum[*LANG_ENUM], :default => :lua

  def self.public
    all(:private => false)
  end

  def self.sorted
    all(:order => [ :created_at.desc ])
  end

  def self.recent n 
    all(:limit => n)
  end
end
