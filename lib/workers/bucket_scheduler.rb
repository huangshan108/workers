module Workers
  class BucketScheduler
    DEFAULT_BUCKET_SIZE = 100
    DEFAULT_POOL_SIZE = 1

    def initialize(options = {})
      options[:bucket_size] ||= DEFAULT_BUCKET_SIZE
      options[:pool_size] ||=  DEFAULT_POOL_SIZE

      @logger = Workers::LogProxy.new(options[:logger])
      @options = options

      @schedulers = (0...(options[:bucket_size])).map {
        Workers::Scheduler.new(:pool => Workers::Pool.new(:logger => @logger, :size => options[:pool_size]))
      }
    end

    def schedule(timer)
      @schedulers[timer.hash % @options[:bucket_size]].schedule(timer)

      nil
    end

    def unschedule(timer)
      @schedulers[timer.hash % @options[:bucket_size]].unschedule(timer)

      nil
    end

    def wakeup
      @schedulers.each { |s| s.wakeup }

      nil
    end

    def dispose
      @schedulers.each { |s| s.dispose }

      nil
    end
  end
end