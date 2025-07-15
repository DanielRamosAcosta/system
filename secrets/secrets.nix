let
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbY3wkjCRVMOYKWfe2mBw8IwSBF7OO/HiF8l+npQg/t";
  playground = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDERMhNP8G9bE9Znd1omaMAGI54L6lil8v7mRaEgzD8G";
  dani = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq21O6t1Q2QHfp9ypCIeDUqJ0PjauigrMXKKvvVL4I/";
in
{
  "dani-hashed-password.age".publicKeys = [ nas playground dani ];
  "immich-password.age".publicKeys = [ nas playground dani ];
  "authelia-password.age".publicKeys = [ nas playground dani ];
}
