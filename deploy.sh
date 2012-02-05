#!/bin/bash

sudo cp agent/* /etc/puppet/modules/mcollective/files/plugins/agent/
sudo cp application/* /etc/puppet/modules/mcollective/files/plugins/application/
# So I can see errors
sudo puppet agent --verbose --no-daemonize --onetime
# Same thing but on all hosts
sudo mco puppetd runonce
# Reload mco agents
sudo mco controller reload_agents
