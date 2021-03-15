# frozen_string_literal: true

module CableReady
  class Channel
    include Operational

    attr_reader :identifier

    def initialize(identifier)
      @identifier = identifier
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
