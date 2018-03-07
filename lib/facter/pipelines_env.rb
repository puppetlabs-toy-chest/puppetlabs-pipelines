require 'tmpdir'

# This is use on Windows to find the correct paths for things
Facter.add(:pipelines_env) do
  confine :kernel => "windows"
  setcode {
    {
      "TEMP" => ENV['TEMP'] || Dir.tmpdir,
      "ProgramFiles" => ENV["ProgramFiles"],
      "SystemDrive" => ENV["SystemDrive"],
    }
  }
end
