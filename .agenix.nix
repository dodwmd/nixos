let
  dodwmd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1Vk18qExSQM6rksG500xD/mgACFpNyh7mRnrhVVUQx michael@dodwell.us";

  users = [ dodwmd ];

  # Pre-provisioned host keys (stable across reinstalls)
  k3s-master-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOG3xfyiYGx0o7neZG83FUSkJOA8fDnW2fiPyE4D47zb root@k3s-master-01";
  k3s-master-02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzdYTEpl7VuLWXEpGD2RrISgWiAVUuJ3QS1qD9Xu6cg root@k3s-master-02";
  k3s-worker-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbeGoKL3dfjdr0RVUrnGF+Veza4c3JTNwU5GG85Gy2m root@k3s-worker-01";
  k3s-worker-02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9C+c9uwvbVcaVOUhhZPHJt6vy3k5nrC+5p0n7wHlqV root@k3s-worker-02";
  k3s-worker-03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5zZPFDXB8Q0fOjrRbcf+5mrxNaVrWyndYDZnlVQMap root@k3s-worker-03";

  systems = [ k3s-master-01 k3s-master-02 k3s-worker-01 k3s-worker-02 k3s-worker-03 ];

  masters = [ k3s-master-01 k3s-master-02 ];

  allKeys = users ++ systems;
in
{
  # K3s cluster token - all k3s nodes + user can decrypt
  "secrets/k3s-token.age".publicKeys = allKeys;

  # K3s CA keypairs - masters + user only (workers don't need these)
  # Seeded into /var/lib/rancher/k3s/server/tls/ before k3s starts
  # so certs survive NixOS rebuilds and never go out of sync with the token
  "secrets/k3s-ca/server-ca.crt.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/server-ca.key.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/client-ca.crt.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/client-ca.key.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/request-header-ca.crt.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/request-header-ca.key.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/etcd-peer-ca.crt.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/etcd-peer-ca.key.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/etcd-server-ca.crt.age".publicKeys = users ++ masters;
  "secrets/k3s-ca/etcd-server-ca.key.age".publicKeys = users ++ masters;

  # Host private keys - only user (exodus) can decrypt, for bootstrapping via nixos-anywhere
  "secrets/host-keys/k3s-master-01.age".publicKeys = users ++ [ k3s-master-01 ];
  "secrets/host-keys/k3s-master-02.age".publicKeys = users ++ [ k3s-master-02 ];
  "secrets/host-keys/k3s-worker-01.age".publicKeys = users ++ [ k3s-worker-01 ];
  "secrets/host-keys/k3s-worker-02.age".publicKeys = users ++ [ k3s-worker-02 ];
  "secrets/host-keys/k3s-worker-03.age".publicKeys = users ++ [ k3s-worker-03 ];
}
