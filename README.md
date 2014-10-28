# mcollective-yum-agent

Borrowing from the built in Puppetlabs Package agent, I wanted a yum-centric agent for my environment

##  This repo has been renamed 

I have wanted for a while to split out the two agents contained here and I am finally doing it.

This repository will only contain the Yum agent, while I have moved the shellout agent to:

  Shellout agent: https://github.com/slaney/mcollective-shellout-agent

## Install

Install via config management via any pattern you prefer.  There is an included spec file if you'd like to roll an rpm and deploy via config management with a package.

## Usage

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

List packages
  
    sudo mco rpc yum list # defaults to all
    sudo mco rpc yum list option="installed" # valid options are: 'installed', 'all', 'available', 'extras', 'obsoletes', 'updates'
    sudo mco rpc yum list option="all" packages="kernel"

Clean various caches // Note: I borrowed this code from the main mcollective plugins repo:

    sudo mco rpc yum clean # This defaults to all if package.yum_clean_mode set
    sudo mco rpc yum clean mode=all
    sudo mco rpc yum clean mode=headers
    sudo mco rpc yum clean mode=packages
    sudo mco rpc yum clean mode=metadata
    sudo mco rpc yum clean mode=dbcache
    sudo mco rpc yum clean mode=plugins
    sudo mco rpc yum clean mode=expire-cache
