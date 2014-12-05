metadata :name       => "Yum Agent",
  :description       => "This is an agent for invoking yum actions on nodes",
  :author            => "Nathan Powell <nathan@nathanpowell.org>",
  :liberal_borrowing => "From here:  https://github.com/puppetlabs/mcollective-plugins/tree/master/agent/package/agent",
  :license           => "Apache License, Version 2.0",
  :version           => "1.0",
  :url               => "http://nathanpowell.org/",
  :timeout           => 600

action "simpleresponse" , :description => "Responds on execution" do
  display :always

  output :output,
    :description => "Output from YUM",
    :display_as  => "Output"
end

["install", "downgrade", "remove", "reinstall"].each do |act|
    action act, :description => "#{act.capitalize} a package" do
        input :package,
              :prompt      => "Package Name",
              :description => "Package to #{act}",
              :type        => :string,
              :validation  => '.',
              :optional    => false,
              :maxlength   => 90

        output :output,
               :description => "Output from yum",
               :display_as  => "Output"
    end
end

action "list", :description => "List all packages" do
  display :always

  output :output,
    :description => "Output from Yum",
    :display_as  => "Output"
end

action "update", :description => "Update all packages or individual packages to current patch levels" do
  input :package,
    :prompt      => "Package Name",
    :description => "Package to update",
    :type        => :string,
    :validation  => '.',
    :optional    => true,
    :maxlength   => 0

  output :output,
    :description => "Output from Yum",
    :display_as  => "Output"
end

action "downloadonly", :description => "Stage packages on individual nodes" do
  display :always

  output :output,
    :description => "Output from Yum",
    :display_as  => "Output"
end

# https://github.com/slaney/mcollective-yum-agent/pull/4
["check_update", "check-update"].each do |act|
  action act, :description => "Check for outdated packages" do
    display :always

    output :output,
      :description => "Output from Yum",
      :display_as  => "Output"

    output :oudated_packages,
      :description => "Outdated packages",
      :display_as  => "Outdated Packages"

    output :exitcode,
      :description => "The exitcode from the yum command",
      :display_as => "Exit Code"

  end
end

action "clean", :description => "Clean the yum cache" do
  input :mode,
    :prompt      => "Yum clean mode",
    :description => "One of the various supported clean modes",
    :type        => :list,
    :optional    => true,
    :list        => ["all", "headers", "packages", "metadata", "dbcache", "plugins", "expire-cache"]

  output :output,
    :description => "Output from YUM",
    :display_as  => "Output"

  output :exitcode,
    :description => "The exitcode from the yum command",
    :display_as => "Exit Code"
end
