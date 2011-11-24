require 'forwardable'
require 'rack/session/abstract/id'
require 'dm-core'

module Rack
  module Session
    class DataMapperSession
      include DataMapper::Resource

      property :id, String, :length => 64, :key => true
      property :data_object, Object, :default => lambda { |r, p| {} }

      def each &block
        data.each &block
      end

      def data
        data_object
      end

      def data= value
        update(:data_object => value)
      end
    end

    class DataMapper < Abstract::ID
      attr_reader :mutex, :pool

      def initialize app, options={}
        super
        @pool = Hash.new
        @mutex = Mutex.new
      end

      def generate_sid
        loop do
          sid = super
          # This might not be really smart...
          break sid if DataMapperSession.get(sid).nil?
        end
      end

      def get_session env, sid
        with_lock(env, [nil, {}]) do
          unless sid and session = DataMapperSession.get(sid)
            sid, session = generate_sid, DataMapperSession.create(:id => sid)
          end
          [sid, session]
        end
      end

      def set_session env, sid, new_session, options
        with_lock(env, false) do
          session = DataMapperSession.get(sid) || DataMapperSession.create(:id => sid)
          session.data = new_session
          sid
        end
      end

      def destroy_session env, sid, options
        with_lock(env) do
          DataMapperSession.get(sid).destroy
          generate_sid unless options[:drop]
        end
      end

      def with_lock env, default=nil
        @mutex.lock if env['rack.multithread']
        yield
      rescue
        default
      ensure
        @mutex.unlock if @mutex.locked?
      end
    end
  end
end
