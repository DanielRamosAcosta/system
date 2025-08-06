let
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4Chuh+45HCl+jMi7xjDgquT8bqZ0S53av6uhgzPiZl";
  dani = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq21O6t1Q2QHfp9ypCIeDUqJ0PjauigrMXKKvvVL4I/";
in
{
  "dani-hashed-password.age".publicKeys = [ nas dani ];
}
