module Mandy
  module Reducers
    class Base < Mandy::Task
      include Mandy::IO::OutputFormatting

      def self.compile(opts={}, &blk)
        Class.new(Mandy::Reducers::Base) do 
          self.class_eval do
            define_method(:reducer, blk) if blk
            define_method(:setup, opts[:setup]) if opts[:setup]
            define_method(:teardown, opts[:teardown]) if opts[:teardown]
          end
        end
      end
    
      def execute
        setup if self.respond_to?(:setup)
        last_key, values = nil, []
        @input.each_line do |line|
           key, value = line.split(KEY_VALUE_SEPERATOR, 2)
           value.chomp!
           last_key = key if last_key.nil?
           if key != last_key
             reducer(last_key, values)
             last_key, values = key, []
           end
           values << value
        end
        reducer(deserialize_key(last_key), values.map {|v| deserialize_value(v) })
        teardown if self.respond_to?(:teardown)
      end
    
      private
      
      def reducer(key,values)
        #nil
      end
    end
  end
end