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

     sudo mco rpc yum check-update

Patch all hosts to the latest patch level (either by repo, rhn or satellite sync):

     sudo mco rpc yum update # note this is the same thing as concurrently running `yum update -y` on ALL hosts 

Stage all available patches on servers (that have the downloadonly plugin)
  
     sudo mco rpc yum downloadonly

Stage a specfic package on servers (that have the downloadonly plugin)
  
     sudo mco rpc yum downloadonly package=xclock

Clean various caches // Note: I borrowed this code from the main mcollective plugins repo:

     sudo mco rpc yum clean # This defaults to all if package.yum_clean_mode set
     sudo mco rpc yum clean mode=all
     sudo mco rpc yum clean mode=headers
     sudo mco rpc yum clean mode=packages
     sudo mco rpc yum clean mode=metadata
     sudo mco rpc yum clean mode=dbcache
     sudo mco rpc yum clean mode=plugins
     sudo mco rpc yum clean mode=expire-cache
  

### Usage Shellout agent:

The Shellout agent allows concurrent remote execution of arbitrary shell
commands.  I hope that sounds as scary as I mean it to sound.  You need to make
sure you give due diligence to security on the clients that have access to this
agent.

Example usage 1 (outputs STDOUT):

     sudo mco rpc shellout cmd cmd='for i in $(seq 1 10);do echo $i;done'

Example usage 2 (outputs STDERR):

     sudo mco rpc shellout cmd cmd='ls -l /home/jbeiber/awesome-songs.txt'
