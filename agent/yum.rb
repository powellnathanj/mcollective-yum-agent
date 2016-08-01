# Most of this agent was taken, verbatim, from the Packages agent.
# Rather than muddy the waters by forking that agent I created a 
# separate agent that is ONLY concerned with Yum...(I live in an Ivory Tower
# where I only need to worry about RHEL)

# This also needs to be a bit more transparent to what's going on and handling failures
module MCollective
  module Agent
    class Yum<RPC::Agent
      metadata :name      => "Yum Agent",
       :description       => "This is an agent for invoking yum actions on nodes",
       :author            => "Nathan Powell <nathan@nathanpowell.org>",
       :liberal_borrowing => "From here:  https://github.com/puppetlabs/mcollective-plugins/tree/master/agent/package/agent",
       :license           => "Apache License, Version 2.0",
       :version           => "1.0",
       :url               => "http://nathanpowell.org/",
       :timeout           => 600

      ["install", "downgrade", "remove", "reinstall"].each do |act|
        action act do
          validate :package, :shellsafe
          do_yum_action(request[:package], act.to_sym)
        end
      end

      action "list" do
        check_for_yum

        valid_options = ['installed', 'all', 'available', 'extras', 'obsoletes', 'updates']
        args = ""

        if request[:option]
          if valid_options.include? request[:option]
            args << "#{request.data[:option]} "
          else
            reply.fail! "Invalid option: #{request.data[:option]}"
          end
        end

        if request[:packages]
          validate :packages, :shellsafe
          args << " #{request.data[:packages]} "
        end

        reply[:exitcode] = run("/usr/bin/yum list #{args}", :stdout => :output, :chomp => true)
      end

      # Not sure how I feel about this yet, but I do want the functionality
      action "update" do
        check_for_yum
        if request[:package]
          validate :package, :shellsafe
          do_yum_action(request[:package], :update)
        else
          # This is still dangerous, if you accidently misspell `package=...`
          # it will default to `yum update -y` but there is no nice way around
          # this: https://tickets.puppetlabs.com/browse/MCO-55
          reply[:exitcode] = run("/usr/bin/yum update -y", :stdout => :output, :chomp => true)
        end
      end

      # If you install the yum downloadonly plugin this can speed up patching by allowing you to 
      # pre-stage patches before your window.
      action "downloadonly" do
        check_for_yum
        reply.fail! "downloadonly plugin not found!" unless File.exist?("/usr/lib/yum-plugins/downloadonly.py")
        if request[:package]
          validate :package, :shellsafe
          reply[:exitcode] = run("/usr/bin/yum install #{request[:package]} -y --downloadonly", :stdout => :output, :chomp => true)
        else
          reply[:exitcode] = run("/usr/bin/yum update -y --downloadonly", :stdout => :output, :chomp => true)
        end
      end

      # https://github.com/slaney/mcollective-yum-agent/pull/4
      ["check_update", "check-update"].each do |act|
        action act do
          check_for_yum

          reply[:exitcode] = run("/usr/bin/yum -q check-update", :stdout => :output, :chomp => true)

          if reply[:exitcode].zero?
            reply[:outdated_packages] = []
            # Exit code 100 means package updates available
          elsif reply[:exitcode] == 100
            reply[:outdated_packages] = do_outdated_packages(reply[:output])
          else
            reply.fail! "`yum check-update` failed with exit code: #{reply[:exitcode]}"
          end
        end
      end

      action "clean" do
        check_for_yum

        clean_mode = if request[:mode]
                       request[:mode]
                     else
                       @config.pluginconf["package.yum_clean_mode"] || "all"
                     end

        if ["all", "headers", "packages", "metadata", "dbcache", "plugins", "expire-cache"].include?(clean_mode)
            reply[:exitcode] = run("/usr/bin/yum clean #{clean_mode}", :stdout => :output, :chomp => true)
        else
          reply.fail! "Unsupported yum clean mode: #{clean_mode}"
        end

        reply.fail! "Yum clean failed, exit code was #{reply[:exitcode]}" unless reply[:exitcode].zero?
      end

      # Helper methods
      private
      def check_for_yum
        reply.fail! "Cannot find yum at /usr/bin/yum" unless File.exist?("/usr/bin/yum")
      end

      def do_yum_action(package, action)
        check_for_yum

        reply[:exitcode] = run("/usr/bin/yum #{action} #{package} -y", :stdout => :output, :chomp => true)
      end

      def do_outdated_packages(packages)
        outdated_pkgs = []
        cleaned_packages = if packages =~ /^Obsoleting\sPackages/
                             packages[/(.*?)(?:Obsoleting\sPackages).*/m, 1]
                           else
                             packages.strip
                           end
        cleaned_packages.scan(/\s*(\S+)\s*(\S+)\s*(\S+)/).each do |package|
          pkg, ver, repo = package
          if pkg && ver && repo
            pkginfo = {
              :package => pkg.strip,
              :version => ver.strip,
              :repo => repo.strip
            }
            outdated_pkgs << pkginfo
          end
        end
        outdated_pkgs
      end
    end
  end
end

