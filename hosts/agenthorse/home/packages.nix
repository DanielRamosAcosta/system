{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh
    jira-cli-go
    snowflake-cli
    asdf-vm
    jq
    unzip
    gnupg
  ];
}
