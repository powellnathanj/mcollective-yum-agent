mcollective agents and applications for things I need

I just started learning/using mcollective, so please vet all code you use from here yourself.  If you find anything remiss please open an issue.

These are only tested against 1.3.2, so if you are using 1.2.1 (the latest stable release, YMMV)

### First, about the Yum agent:
I made liberal use of the code contained in the main mcollective repo:

  https://github.com/puppetlabs/mcollective-plugins/tree/master/agent/package/agent

However, I wanted it to be yum-centric for my environment.

### Usage Yum agent:

Install a package on all hosts:

     sudo mco rpc yum install xclock

Upgrade a package on all hosts:

     sudo mco rpc yum upgrade xclock

Reinstall a package on all hosts:

     sudo mco rpc yum reinstall xclock

Check for available updates:

     sudo mco rpc yum checkupdates

Patch all hosts to the latest patch level (either by repo, rhn or satellite sync):

     sudo mco rpc yum update # note this is the same thing as concurrently running `yum update -y` on ALL hosts 

Clean various caches // Note: I borrowed this code from the main mcollective plugins repo:

     sudo mco rpc yum clean # This defaults to all if package.yum_clean_mode set
     sudo mco rpc yum clean mode=all
     sudo mco rpc yum clean mode=headers
     sudo mco rpc yum clean mode=packages
     sudo mco rpc yum clean mode=metadata
     sudo mco rpc yum clean mode=dbcache
     sudo mco rpc yum clean mode=plugins
     sudo mco rpc yum clean mode=expire-cache
  

