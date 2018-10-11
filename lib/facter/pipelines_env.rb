# This is use on Windows to find the correct paths for things
Facter.add(:pipelines_env) do
  confine kernel: 'windows'
  setcode do
    {
      'ProgramFiles' => ENV['ProgramFiles'],
      'SystemDrive' => ENV['SystemDrive'],
    }
  end
end
