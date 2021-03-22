module CableReady
  class OperationBuilder
    def initialize
      reset!
      CableReady.config.operation_names.each { |name| add_operation_method name }

      config_observer = self
      CableReady.config.add_observer config_observer, :add_operation_method
      ObjectSpace.define_finalizer self, -> { CableReady.config.delete_observer config_observer }
    end

    def add_operation_method(name)
      return if respond_to?(name)

      singleton_class.public_send :define_method, name, ->(options = {}) {
        @enqueued_operations[name.to_s] << options.stringify_keys
      }
    end

    def to_json(*args)
      @enqueued_operations.to_json(*args)
    end

    def apply(operations = "{}")
      operations = begin
        JSON.parse(operations.is_a?(String) ? operations : operations.to_json)
      rescue JSON::ParserError
        {}
      end
      operations.each do |key, operation|
        operation.each do |enqueued_operation|
          @enqueued_operations[key.to_s] << enqueued_operation
        end
      end
      self
    end

    def operations_payload
      @enqueued_operations.select { |_, list| list.present? }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    def reset!
      @enqueued_operations = Hash.new { |hash, key| hash[key] = [] }
    end
  end
end
