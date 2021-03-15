module CableReady
  module Operational
    def operation_builder
      @operation_builder ||= OperationBuilder.new
    end

    def respond_to_missing?(method_name, include_private = true)
      operation_builder.respond_to?(method_name) || super
    end

    def method_missing(sym, *args)
      if operation_builder.respond_to?(sym)
        operation_builder.send(sym, *args)
        self
      else
        super
      end
    end
  end
end
