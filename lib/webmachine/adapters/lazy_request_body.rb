
module Webmachine
  module Adapters
    # Wraps a request body so that it can be passed to
    # {Request} while still lazily evaluating the body.
    class LazyRequestBody
      def initialize(request)
        @request = request
      end

      # Converts the body to a String so you can work with the entire
      # thing.
      def to_s
        @value ? @value.join : @request.body
      end

      # Converts the body to a String and checks if it is empty.
      def empty?
        to_s.empty?
      end

      # Iterates over the body in chunks. If the body has previously
      # been read, this method can be called again and get the same
      # sequence of chunks.
      # @yield [chunk]
      # @yieldparam [String] chunk a chunk of the request body
      def each
        if @value
          @value.each {|chunk| yield chunk }
        else
          @value = []
          @request.body {|chunk| @value << chunk; yield chunk }
        end
      end
        
      # Read body data from the request
      # @param [Integer] optional length of data to read
      # @param [String]  optional buffer to recieve the data
      # @return [String,nil] result of read operation
      def read(length = nil, buffer = nil)
        if @request.is_a?(::IO)
          @request.read(length, buffer)
        elsif @request.respond_to?(:read) # quacks like
          @request.read(length, buffer)
        else
          case length
          when nil
            buffer ? buffer << self.to_s : self.to_s
          else
            raise ArgumentError, "Unable to fulfill read with a length argument on this request type"
          end
        end
      end
    end # class RequestBody
  end # module Adapters
end # module Webmachine
