let
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbY3wkjCRVMOYKWfe2mBw8IwSBF7OO/HiF8l+npQg/t";
  nas-gce = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5PGS9h8WyuI7vy3WSz9cf+yencFRs3+ta7bBmVg+Om";
  dani = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq21O6t1Q2QHfp9ypCIeDUqJ0PjauigrMXKKvvVL4I/";
in
{
  "dani-hashed-password.age".publicKeys = [ nas nas-gce dani ];
}
