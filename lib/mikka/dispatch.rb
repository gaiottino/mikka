module Mikka
  DISPATCHER_REGISTRY = {}
  
  module DispatcherDsl
    module ClassMethods
      def dispatcher(type, config={})
        @dispatcher_type = type
        @dispatcher_config = config
      end

      def dispatcher_type
        @dispatcher_type
      end
      
      def dispatcher_config
        @dispatcher_config
      end
      
    end
  
    module InstanceMethods
      def initialize(*args)
        super
        
        type = self.class.dispatcher_type
        config = self.class.dispatcher_config
        
        case type
        when :event_driven
          name = config.delete(:name)
          raise ArgumentError, ":name must be supplied" unless name
          dispatcher = event_driven_dispatcher(name, config)
        when :thread_based
          dispatcher = thread_based_dispatcher(context, config)
        else raise ArgumentError, "type must be one of :thread_based"
        end
        
        context.dispatcher = dispatcher if dispatcher
      end
      
    private

      def event_driven_dispatcher(name, config)
        if DISPATCHER_REGISTRY[name]
          @dispatcher = DISPATCHER_REGISTRY[name]
        else
          builder = Akka::Dispatch::Dispatchers.new_executor_based_event_driven_dispatcher(name)
          builder.set_core_pool_size(config[:core_pool_size]) if config[:core_pool_size]
          builder.set_max_pool_size(config[:max_pool_size]) if config[:max_pool_size]
          @dispatcher = builder.build
          DISPATCHER_REGISTRY[name] = @dispatcher
        end
        @dispatcher
      end
      
      def thread_based_dispatcher(context, config)
        @dispatcher = Akka::Dispatch::Dispatchers.new_thread_based_dispatcher(context)
      end
    end
    
    def self.included(m)
      m.extend(ClassMethods)
      m.include(InstanceMethods)
    end
  end
end