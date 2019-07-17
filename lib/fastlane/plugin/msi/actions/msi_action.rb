require 'fastlane/action'
require_relative '../helper/msi_helper'

module Fastlane
  module Actions
    class MsiAction < Action
      def self.run(params)
        UI.user_error! 'Could not find wixl. Please make sure to install msitools before running msi' if `which wixl`.empty?

        fragments = params[:fragments]
        fragment_files = unless fragments.nil? or fragments.empty?
          fragments.map do |fragment, options|
            UI.message "Generating fragment for #{fragment}"
            fragment_path = options[:path]
            UI.user_error! "No path specified for fragment #{fragment}" if fragment_path.nil? or fragment_path.empty?
            UI.user_error! "Nothing found at #{fragment_path}" if Dir.glob(fragment_path).empty?

            fragment_file = "#{fragment}.wxs"

            command_builder = ["find #{fragment_path} | wixl-heat"]
            command_builder << "--prefix #{options[:prefix]}" if options[:prefix]
            command_builder << "--directory-ref #{options[:directory_ref]}" if options[:directory_ref]
            command_builder << "--exclude #{options[:exclude]}" if options[:exclude]
            command_builder << "--var #{options[:var]}" if options[:var]
            command_builder << "--component-group #{options[:component_group]}" if options[:component_group]
            command_builder << '--win64' if options[:win64]
            command_builder << "> #{fragment_file}"

            sh(command_builder.join(' '))
            UI.success "Successfully generated fragment for #{fragment}"

            fragment_file
          end
        end

        UI.message fragment_files.inspect
        UI.message Dir.pwd
        UI.message `find *`
        UI.message File.exist? params[:wxs_path]

        command_builder = ["wixl #{params[:wxs_path]}"]
        command_builder << fragment_files.join(' ') if fragment_files
        command_builder << params[:defines].map { |k,v| "-D #{k}=#{v}" }.join(' ') if params[:defines]
        command_builder << "--output #{params[:output]}" if params[:output]
        command_builder << "--arch #{params[:architecture]}" if params[:architecture]
        command_builder << '-v'

        sh(command_builder.join(' '))
      end

      def self.description
        'Create Windows Installer'
      end

      def self.authors
        ['Paul Niezborala']
      end

      def self.return_value
        'The path to the created .msi file'
      end

      def self.details
        'MSI enables you to package builds into MSI files to create installer for windows'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :wxs_path,
                                  env_name: 'MSI_WXS_PATH',
                               description: 'The path to the .wxs file used to build',
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :output,
                                  env_name: 'MSI_OUT_PATH',
                               description: 'The path to output the .msi to',
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :fragments,
                                  env_name: 'MSI_FRAGMENTS',
                               description: 'The various additional components to dynamically generate',
                                  optional: true,
                                      type: Hash),
          FastlaneCore::ConfigItem.new(key: :defines,
                                  env_name: 'MSI_DEFINES',
                               description: 'The various defines to create your msi with',
                                  optional: true,
                                      type: Hash),
          FastlaneCore::ConfigItem.new(key: :architecture,
                                  env_name: 'MSI_ARCHITECTURE',
                               description: 'The architecture you want to build for',
                                  optional: true,
                                      type: String),
        ]
      end

      def self.is_supported?(platform)
        platform == :windows
      end
    end
  end
end
