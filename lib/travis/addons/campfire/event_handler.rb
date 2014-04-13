module Travis
  module Addons
    module Campfire

      # Publishes a build notification to campfire rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Campfire credentials are encrypted using the repository's ssl key.
      class EventHandler < Event::Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def handle?
          enabled? && targets.present? && config.send_on_finished_for?(:campfire)
        end

        def handle
          Travis::Addons::Campfire::Task.run(:campfire, payload, targets: targets)
        end

        def targets
          @targets ||= config.notification_values(:campfire, :rooms)
        end

        private

          def enabled?
            enabled = config.notification_values(:campfire, :on_pull_requests)
            enabled = false if enabled.nil? or !(!!enabled == enabled) # configuration returns a non boolean if key is not found
            pull_request? ? enabled : true
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end
