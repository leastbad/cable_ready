# frozen_string_literal: true

require "thread/local"

module CableReady
  class CableCar
    include Operational
    extend Thread::Local

    def ride(clear: true)
      payload = @operation_builder.operations_payload
      @operation_builder.reset! if clear
      payload
    end
  end
end
