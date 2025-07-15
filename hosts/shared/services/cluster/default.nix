{
  imports = [
    ./namespaces/databases.nix
    ./charts/dashboard.nix
    ./charts/postgres.nix
    ./charts/sealed-secrets.nix
    ./accounts/admin.nix
  ];
}
