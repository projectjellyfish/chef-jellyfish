# Configure VM Ram usage
Vagrant::Config.run do |config|
  config.chef_zero.chef_repo_path = '/tmp/kitchen/'
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      'postgresql' => {
        'password' => {
          'postgres' => 'myPassword'
        }
      }
    }
  end
end
config.vm.customize [
  'modifyvm', :id,
  '--memory', '1024'
]
