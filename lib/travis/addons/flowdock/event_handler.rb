module Travis
  module Addons
    module Flowdock

      # Publishes a build notification to Flowdock rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Flowdock credentials are encrypted using the repository's ssl key.
      class EventHandler < Event::Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def initialize(*)
          super
          @payload = Api.data(object, for: 'event', version: 'v0', params: data)
        end

        def handle?
          enabled? && targets.present? && config.send_on_finished_for?(:flowdock)
        end

        def handle
          Travis::Addons::Flowdock::Task.run(:flowdock, payload, targets: targets)
        end

        def targets
          @targets ||= config.notification_values(:flowdock, :rooms)
        end

        private

          def enabled?
            enabled = config.notification_values(:flowdock, :on_pull_requests)
            enabled = false if enabled.nil? or !(!!enabled == enabled) # configuration returns a non boolean if key is not found
            pull_request? ? enabled : true
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

