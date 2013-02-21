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
       :timeout            => 300

      ["install", "remove", "reinstall"].each do |act|
        action act do
          validate :package, :shellsafe
          do_yum_action(request[:package], act.to_sym)
        end
      end

      # Not sure how I feel about this yet, but I do what the functionality
      action "update" do
        reply.fail! "Cannot find yum at /usr/bin/yum" unless File.exist?("/usr/bin/yum")
        reply[:exitcode] = run("/usr/bin/yum update -y", :stdout => :output, :chomp => true)
      end

      # If you install the yum downloadonly plugin this can speed up patching by allowing you to 
      # pre-stage patches before your window.
      action "downloadonly" do
        reply.fail! "downloadonly plugin not found!" unless File.exist?("/usr/lib/yum-plugins/downloadonly.py")
        if request[:package]
          run("echo 'foobar' >> /tmp/hellothere")
          reply[:exitcode] = run("/usr/bin/yum install #{request[:package]} -y --downloadonly", :stdout => :output, :chomp => true)
        else
          reply[:exitcode] = run("/usr/bin/yum update -y --downloadonly", :stdout => :output, :chomp => true)
        end
      end

      action "check-update" do
        reply.fail! "Cannot find yum at /usr/bin/yum" unless File.exist?("/usr/bin/yum")
        reply[:exitcode] = run("/usr/bin/yum -q check-update", :stdout => :output, :chomp => true)

        if reply[:exitcode] == 0
          reply[:outdated_packages] = []
          # Exit code 100 means package updates available
        elsif reply[:exitcode] == 100
          reply[:outdated_packages] = do_outdated_packages(reply[:output])
        else
          reply.fail! "`yum check-update` failed with exit code: #{reply[:exitcode]}"
        end
      end

      action "clean" do
        reply.fail! "Cannot find yum at /usr/bin/yum" unless File.exist?("/usr/bin/yum")

        if request[:mode]
          clean_mode = request[:mode]
        else
          clean_mode = @config.pluginconf["package.yum_clean_mode"] || "all"
        end

        if ["all", "headers", "packages", "metadata", "dbcache", "plugins", "expire-cache"].include?(clean_mode)
            reply[:exitcode] = run("/usr/bin/yum clean #{clean_mode}", :stdout => :output, :chomp => true)
        else
          reply.fail! "Unsupported yum clean mode: #{clean_mode}"
        end

        reply.fail! "Yum clean failed, exit code was #{reply[:exitcode]}" unless reply[:exitcode] == 0
      end

      # Helper methods
      private
      def do_yum_action(package, action)
        reply.fail! "Cannot find yum at /usr/bin/yum" unless File.exist?("/usr/bin/yum")

        reply[:exitcode] = run("/usr/bin/yum #{action} #{package} -y", :stdout => :output, :chomp => true)
      end

      def do_outdated_packages(packages)
        outdated_pkgs = []
        packages.strip.each_line do |line|
          # Don't handle obsoleted packages for now
          break if line =~ /^Obsoleting\sPackages/i

          pkg, ver, repo = line.split
          if pkg && ver && repo
            pkginfo = { :package => pkg.strip,
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

