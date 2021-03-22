# frozen_string_literal: true

module CableReady
  class Channel
    include Operational

    attr_reader :identifier

    def self.finalizer_for(identifier)
      proc {
        channel = CableReady.config.observers.find { |o| o.try(:identifier) == identifier }
        CableReady.config.delete_observer channel if channel
      }
    end

    def initialize(identifier)
      @identifier = identifier
      reset
      CableReady.config.operation_names.each { |name| add_operation_method name }
      CableReady.config.add_observer self, :add_operation_method
      ObjectSpace.define_finalizer self, self.class.finalizer_for(identifier)
    end

    def broadcast(clear: true)
      ActionCable.server.broadcast identifier, {"cableReady" => true, "operations" => operation_builder.operations_payload}
      operation_builder.reset! if clear
    end

    def broadcast_to(model, clear: true)
      identifier.broadcast_to model, {"cableReady" => true, "operations" => operation_builder.operations_payload}
      operation_builder.reset! if clear
    end
  end
end
