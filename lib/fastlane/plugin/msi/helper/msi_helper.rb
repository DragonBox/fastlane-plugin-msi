require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class MsiHelper
      # class methods that you define here become available in your action
      # as `Helper::MsiHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the msi plugin helper!")
      end
    end
  end
end
