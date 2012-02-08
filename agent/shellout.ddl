metadata :name  => "Remote arbitrary shell execution",
  :description  => "An agent for executing shell commands (like the 'for i in $(whateevr)'...that you started using mco to get away from..but concurrent!)",
  :author       => "Nathan Powell <nathan@nathanpowell.org>",
  :license      => "Apache License, Version 2.0",
  :version      => "1.0",
  :url          => "http://nathanpowell.org/",
  :timeout      => 90

action "cmd" , :description => "Responds on execution" do
  display :always

  output :output,
    :description => "Output from the shell",
    :display_as  => "Output"
end

