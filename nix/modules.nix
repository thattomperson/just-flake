# This largely inspired by the use of freeformType in 
# https://github.com/cachix/git-hooks.nix/blob/master/modules/hooks.nix
{
  pkgs,
  lib,
  path,
  ...
}:

let
  inherit (lib) types;
  moduleMod = {
    imports = [ ./module.nix ];
    config._module.args = {
      inherit pkgs;
      inherit path;
    };
  };
  moduleType = types.submodule moduleMod;
in
{
  imports = [
    {
      options.modules = lib.mkOption {
        type = types.submoduleWith {
          modules = [ { freeformType = types.attrsOf moduleType; } ];
          specialArgs = {
            inherit pkgs;
            inherit path;
          };
        };
        default = { };
      };
    }
  ];
}
