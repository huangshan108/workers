module Workers
  class Actor
    def initialize(options = {})
      @logger = Workers::LogProxy.new(options[:logger])
      @pool = options[:pool] || Workers.pool
      @mailbox = options[:mailbox] || Workers::Mailbox.new
      @registry = options[:registry] || Workers.registry
      @name = options[:name]
      @alive = true
      @alive_mutex = Mutex.new

      @registry.register(self)
    end

    def enqueue(command, data)
      return false unless @alive

      @mailbox.push(Event.new(command, data))

      @pool.perform do
        process_events
      end

      return true
    end

    def alive?
      @alive_mutex.synchronize do
        return @alive
      end
    end

    def name
      return @name
    end

    def identifier
      return @name ? "#{object_id}:#{@name}" : object_id
    end

    private

    def process_events
      while (event = @mailbox.shift)
        case event.command
        when :shutdown
          shutdown_handler(event)
          @alive_mutex.synchronize do
            @alive = false
          end
        else
          process_event(event)
        end
      end
    rescue Exception => e
      @alive = false
      exception_handler(e)
    end

    #
    # Subclass and override the below methods.
    #

    def process_event(event)
      puts "Actor (#{identifier}) received event (#{event.inspect})."
    end

    def exception_handler(e)
      puts concat_e("Actor (#{identifier}) died.", e)
    end

    def shutdown_handler(event)
      puts "Actor (#{identifier}) is shutting down."
    end
  end
end
