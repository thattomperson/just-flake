{
  config,
  name,
  lib,
  pkgs,
  path,
  ...
}:
let
  inherit (lib) types;
  modulesMod = {
    imports = [ ./module.nix ];
    config._module.args = {
      inherit pkgs;
      path = path ++ [ name ];
    };
  };
  modulesType = types.submodule modulesMod;
in
{
  imports = [
    ./features.nix
    {
      options.modules = lib.mkOption {
        type = types.submoduleWith {
          modules = [ { freeformType = types.attrsOf modulesType; } ];
          specialArgs = {
            inherit pkgs;
            path = path ++ [ name ];
          };
        };
        default = { };
      };
    }
  ];

  options = {
    config._modules.args = {
      inherit pkgs;
      path = path ++ [ name ];
    };

    enable = lib.mkOption {
      description = "Enable this module";
      default =
        let
          enabled-modules = lib.any (module: module.enable) (lib.attrsets.attrValues config.modules);
          enabled-features = lib.any (feature: feature.enable) (lib.attrsets.attrValues config.features);
          enabled = enabled-modules || enabled-features;
        in
        enabled;
    };
    outputs.justfile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = ''
        The justfile code for importing this module's justfile.

        See https://just.systems/man/en/modules1190.html
      '';
      default =
        let
          fullpath = path ++ [ name ];
          justfile = pkgs.writeText "${name}.just" ''
            [private]
            default:
              just --list ${lib.strings.concatStringsSep " " fullpath} --justfile {{justfile()}}

            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: module: module.outputs.justfile) config.modules
            )}

            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: feature: feature.outputs.justfile) config.features
            )}
          '';
        in
        if config.enable then "mod ${name} '${justfile}'" else "";
    };
  };
}
