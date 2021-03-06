module Seahorse
  module Client
    module Plugins

      # Defines a helper method for each API operation that builds and
      # sends the named request.
      #
      # # Helper Methods
      #
      # This plugin adds a helper method that lists the availalbe API
      # operations.
      #
      #     client.operation_names
      #     #=> [:api_operation_name1, :api_operation_name2, ...]
      #
      # Additionally, it adds a helper method for each operation.  This helper
      # handles building and sending the appropriate {Request}.
      #
      #     # without OperationMethods plugin
      #     req = client.build_request(:api_operation_name, request_params)
      #     resp = req.send_request
      #
      #     # using the helper method defined by OperationMethods
      #     resp = client.api_operation_name(request_params)
      #
      class OperationMethods < Plugin

        def after_initialize(client)
          unless client.respond_to?(:operation_names)
            add_operation_helpers(client, client.config.api.operations.keys)
          end
        end

        def add_operation_helpers(client, operations)
          client.class.send(:define_method, :operation_names) { operations }
          operations.each do |name|
            client.class.send(:define_method, name) do |*args, &block|
              params = args[0] || {}
              send_options = args[1] || {}
              build_request(name, params).send_request(send_options, &block)
            end
          end
        end

      end
    end
  end
end
