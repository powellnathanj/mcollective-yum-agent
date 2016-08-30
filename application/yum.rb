require 'json'

module MCollective
  class Application
    class Yum < MCollective::Application
      description 'Interact with the yum package manager'

      # FIXME: complete the usage docs
      usage <<-END_OF_USAGE
mco yum [OPTIONS] [FILTERS] <ACTION> <PACKAGE>
Usage: mco yum <PACKAGE> blah blah

<finish off the docs>
END_OF_USAGE

      option :downloadonly,
             description: "Don't update, just download",
             arguments:   ['--downloadonly'],
             type:        :bool

      option :security,
             description: 'Include security relevant packages',
             arguments:   ['--security'],
             type:        :bool

      option :bugfix,
             description: 'Include bugfix relevant packages',
             arguments:   ['--bugfix'],
             type:        :bool

      option :cve,
             description: 'Include packages needed to fix the given CVE',
             arguments:   ['--cve CVE'],
             type:        :array

      option :bz,
             description: 'Include packages needed to fix the given BZ',
             arguments:   ['--bz BZ'],
             type:        :array

      option :'sec-severity',
             description: 'Include security relevant packages, of this severity',
             arguments:   ['--sec-severity SEVERITY'],
             type:        :array

      def handle_message(command, message, *args)
        messages = {
          1 => "Please specify a command. Valid commands are:\n%s",
          2 => "Command must be one of:\n%s",
          3 => "'%s' is not a valid package name"
        }
        send(command, messages[message] % args)
      end

      def post_option_parser(configuration)
        valid_commands = %w(install downgrade remove reinstall list update check-update check_update clean update-minimal)

        handle_message(:abort, 1, valid_commands.join(', ')) if ARGV.empty?
        # the first arg should be a valid command
        if valid_commands.include?(ARGV[0])
          # it is, yay!
          configuration[:command] = ARGV.shift
          # process the rest of the args
          ARGV[0..-1].each do |arg|
            match_data = arg.match(/(.+)=(.+)/)
            if match_data
              arg_name = match_data[1].to_sym
              arg_value = match_data[2]
              if configuration.key? arg_name
                configuration[arg_name] << arg_value
              else
                configuration[arg_name] = [arg_value]
              end
            elsif configuration.key? :packages
              configuration[:packages] << arg
            else
              configuration[:packages] = [arg]
            end
          end
        else
          handle_message(:abort, 2, valid_commands.join(', '))
        end
      end

      def validate_configuration(configuration)
        if configuration.key? :packages
          # make sure the package names are valid
          configuration[:packages].each do |pkg|
            # validate pkg with regex
            handle_message(:abort, 3, pkg) unless pkg =~ /^[a-zA-Z\-_\.0-9\*]+$/
          end
        end

        # flatten the packages, cve, bz, sec-severity arrays into strings
        [:packages, :cve, :bz, :'sec-severity'].each do |param|
          next unless configuration.key? param
          unless configuration[param].empty?
            configuration[param] = configuration[param].join(' ')
          end
        end
      end

      def main
        # We have to change our process name in order to hide name of the
        # service we are looking for from our execution arguments. Puppet
        # provider will look at the process list for the name of the service
        # it wants to manage and it might find us with our arguments there
        # which is not what we really want ...
        $0 = 'mco'

        yum = rpcclient('yum')

        command = configuration[:command]
        configuration.delete :command

        yum_result = yum.send(command, configuration)

        if options[:output_format] == :json
          puts yum_result.to_json
        else
          yum_result.each do |node|
            # remove any whitespace from the start of the output
            node.results[:data][:output].gsub!(%r{\A\s+}, '')
            # remove any whitespace and add a single newline at the end of the output
            node.results[:data][:output].gsub!(%r{\s*\z}, "\n")
            # indent all output (add two spaces to the begining of every line)
            node.results[:data][:output].gsub!(%r{^}, "  ")
            # now print the output
            printf "%s:\n", node.results[:sender]
            printf "%s\n", node.results[:data][:output]
          end
          printrpcstats summarize: true, caption: 'yum %s results' % command
        end
        halt yum.stats
      end
    end
  end
end
