metadata :name      => "A generic shell command agent",
  :description       => "This is an agent for invoking shell commands on nodes",
  :author            => "Nathan Powell <nathan@nathanpowell.org>",
  :license           => "Apache License, Version 2.0",
  :version           => "1.0",
  :url               => "http://nathanpowell.org/",
  :timeout            => 60

action "cmd" , :description => "Responds on execution" do
  display :always

  output :output,
    :description => "Output from the shell",
    :display_as  => "Output"
end

