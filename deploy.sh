#!/bin/bash

# You don't need this, this is just for my dev environment
sudo cp agent/* /etc/puppet/environments/lab/modules/mcollective/files/plugins/agents/
sudo cp application/* /etc/puppet/environments/lab/modules/mcollective/files/plugins/applications/
sudo cp agent/* /usr/libexec/mcollective/mcollective/agent/
sudo cp application/* /usr/libexec/mcollective/mcollective/application/

service mcollective restart
