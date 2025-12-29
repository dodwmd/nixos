let
  dodwmd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1Vk18qExSQM6rksG500xD/mgACFpNyh7mRnrhVVUQx michael@dodwell.us";
  
  users = [ dodwmd ];
  
  systems = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC..." # k3s-master-01 host key (get with: ssh-keyscan k3s-master-01)
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC..." # k3s-master-02 host key
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC..." # k3s-worker-01 host key
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC..." # k3s-worker-02 host key
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC..." # k3s-worker-03 host key
  ];
  
  allKeys = users ++ systems;
in
{
  "k3s-token.age".publicKeys = allKeys;
}
