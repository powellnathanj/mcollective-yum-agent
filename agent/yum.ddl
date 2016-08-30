metadata name:              'Yum Agent',
         description:       'This is an agent for invoking yum actions on nodes',
         author:            'Nathan Powell <nathan@nathanpowell.org>',
         liberal_borrowing: 'From here:  https://github.com/puppetlabs/mcollective-plugins/tree/master/agent/package/agent',
         license:           'Apache License, Version 2.0',
         version:           '1.0',
         url:               'http://nathanpowell.org/',
         timeout:           600

def input_clean_mode
  input :mode,
        prompt:      'Yum clean mode',
        description: 'One of the various supported clean modes',
        type:        :list,
        optional:    true,
        list:        ['all', 'headers', 'packages', 'metadata', 'dbcache', 'plugins', 'expire-cache']
end

def input_packages
  input :packages,
        prompt:      'Package Name(s)',
        description: 'Package(s) to update',
        type:        :string,
        validation:  :shellsafe,
        optional:    true,
        maxlength:   0
end

def input_security
  input :security,
        prompt:      'Include security relevant packages',
        description: 'Include security relevant packages',
        type:        :boolean,
        optional:    true
end

def input_bugfix
  input :bugfix,
        prompt:      'Include bugfix relevant packages',
        description: 'Include bugfix relevant packages',
        type:        :boolean,
        optional:    true
end

def input_cve
  input :cve,
        prompt:      'Include packages needed to fix the given CVE',
        description: 'Include packages needed to fix the given CVE',
        type:        :string,
        validation:  :shellsafe,
        maxlength:   0,
        optional:    true
end

def input_bz
  input :bz,
        prompt:      'Include packages needed to fix the given BZ',
        description: 'Include packages needed to fix the given BZ',
        type:        :string,
        validation:  :shellsafe,
        maxlength:   0,
        optional:    true
end

def input_sec_severity
  input :'sec-security',
        prompt:      'Include security relevant packages, of this severity',
        description: 'Include security relevant packages, of this severity',
        type:        :string,
        validation:  :shellsafe,
        maxlength:   0,
        optional:    true
end

def output_yum
  output :output,
         description: 'Output from yum',
         display_as:  'Output'
end

def output_yum_exit_code
  output :exitcode,
         description: 'The exitcode from the yum command',
         display_as:  'Exit Code'
end

def output_outdated_packages
  output :outdated_packages,
         description: 'Outdated packages',
         display_as:  'Outdated Packages'
end

action 'simpleresponse', description: 'Responds on execution' do
  display :always
  output_yum
end

%w(install downgrade remove reinstall).each do |act|
  action act, description: "#{act.capitalize} a package" do
    input_packages
    output_yum
  end
end

action 'list', description: 'List all packages' do
  display :always
  input_packages
  output_yum
end

%w(update update-minimal).each do |act|
  action act, description: 'Update all packages or individual packages to current patch levels' do
    input_packages
    input_security
    input_bugfix
    input_cve
    input_bz
    input_sec_severity
    output_yum
  end
end


# https://github.com/slaney/mcollective-yum-agent/pull/4
['check_update', 'check-update'].each do |act|
  action act, description: 'Check for outdated packages' do
    display :always
    input_packages
    input_security
    input_bugfix
    input_cve
    input_bz
    input_sec_severity
    output_yum
    output_outdated_packages
    output_yum_exit_code
  end
end

action 'clean', description: 'Clean the yum cache' do
  input_clean_mode
  output_yum
  output_yum_exit_code
end
