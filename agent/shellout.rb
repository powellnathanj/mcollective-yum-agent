# Don't be an idiot.  If you deploy this agent to your servers use ACLs at the MQ level and make 
# DAMN SURE your mco host only allows trusted senior people to authenticate and have sudo access

# There can be no shell safe checks here lest we make the agent useless.  YOU HAVE BEEN WARNED!
module MCollective
  module Agent
    class Shellout<RPC::Agent
      metadata :name  => "Remote arbitrary shell execution",
        :description  => "An agent for executing shell commands (like the 'for i in $(whateevr)'...that you started using mco to get away from..but concurrent!)",
        :author       => "Nathan Powell <nathan@nathanpowell.org>",
        :license      => "Apache License, Version 2.0",
        :version      => "1.0",
        :url          => "http://nathanpowell.org/",
        :timeout      => 90
      action "cmd" do 
	      validate :cmd, String
        run("#{request[:cmd]}", :stdout => :out, :stderr => :err, :chomp => true)
      end
    end
  end
end
