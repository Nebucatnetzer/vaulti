{
  description = "Mainly intended to provide development dependencies";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      poetry2nix,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
        python = pkgs.python312;
        env = poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          groups = [ "dev" ];
          editablePackageSources = {
            vaulti = ./vaulti;
          };
          inherit python;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            env
            pkgs.poetry
          ];
          env = {
            ANSIBLE_VAULT_PASSWORD_FILE = ".example_vault_pass.txt";
          };
        };
      }
    );
}
