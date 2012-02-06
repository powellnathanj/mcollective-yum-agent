mcollective agents and applications for things I need

### First, about the Yum agent:
I took most of the code from the packages agent that is available here:

  https://github.com/puppetlabs/mcollective-plugins/tree/master/agent/package/agent

I didn't want the apt portions, and I wanted to add an action to update all the currently out of date packages.

### Usage Yum agent:

- Install a package on all hosts:

  sudo mco rpc yum install xclock

- Upgrade a package on all hosts:

  sudo mco rpc yum upgrade xclock

- Reinstall a package on all hosts:

  sudo mco rpc yum reinstall xclock

- Patch all hosts to the latest patch level (either by repo, rhn or satellite sync):

  sudo mco rpc yum update # note this is the same thing as concurrently running `yum update -y` on ALL hosts 

- Clean various caches // Note: I borrowed this code from the main mcollective plugins repo 

  sudo mco rpc yum clean # This is the same as the next one, if you don't have package.yum_clean_mode in your config
  sudo mco rpc yum clean mode=all
  sudo mco rpc yum clean mode=headers
  sudo mco rpc yum clean mode=packages
  sudo mco rpc yum clean mode=metadata
  sudo mco rpc yum clean mode=dbcache
  sudo mco rpc yum clean mode=plugins
  sudo mco rpc yum clean mode=expire-cache
  

