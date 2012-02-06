# Don't be an idiot.  If you deploy this agent to your servers use ACLs at the MQ level and make 
# DAMN SURE your mco host only allows trusted senior people senior authentication and sudo access

# There can be no shell safe checks here lest we make the agent useless.  YOU HAVE BEEN WARNED!
module MCollective
  module Agent
    class Shellout<RPC::Agent
      action "so" do 
	validate :msg, String
        run("#{request[:msg]}", :stdout => :out, :stderr => :err, :chomp => true)
        reply[:out]
      end
    end
  end
end
