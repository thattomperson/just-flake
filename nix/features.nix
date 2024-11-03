# This largely inspired by the use of freeformType in 
# https://github.com/cachix/git-hooks.nix/blob/master/modules/hooks.nix
{ pkgs, lib, ... }:

let
  inherit (lib) types;
  featureMod = {
    imports = [ ./feature.nix ];
    config._module.args = {
      inherit pkgs;
    };
  };
  featureType = types.submodule featureMod;
in
{
  imports = [
    {
      options.features = lib.mkOption {
        type = types.submoduleWith {
          modules = [ { freeformType = types.attrsOf featureType; } ];
          specialArgs = {
            inherit pkgs;
          };
        };
        default = { };
      };
    }
  ];

  options.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.just;
    defaultText = lib.literalExpression "pkgs.just";
    example = lib.literalExpression "pkgs.just";
    description = "The just package to use";
  };
}
