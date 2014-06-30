{ config, pkgs, uuid, name, ... }:

with pkgs.lib;
let
  resource = type: mkOptionType {
    name = "resource of type ‘${type}’";
    check = x: x._type or "" == type;
    merge = mergeOneOption;
  };

  machine = mkOptionType {
    name = "GCE machine";
    check = x: x ? gce;
    merge = mergeOneOption;
  };

  # FIXME: move to nixpkgs/lib/types.nix.
  union = t1: t2: mkOptionType {
    name = "${t1.name} or ${t2.name}";
    check = x: t1.check x || t2.check x;
    merge = mergeOneOption;
  };
in
{

  options = {

    name = mkOption {
      example = "my-target-pool";
      default = "nixops-${uuid}-${name}";
      type = types.str;
      description = "Description of the GCE Target Pool. This is the <literal>Name</literal> tag of the target pool.";
    };

    region = mkOption {
      example = "europe-west1";
      type = types.str;
      description = "The GCE region to where the GCE Target Pool instances should reside.";
    };

    healthCheck = mkOption {
      default = null;
      example = "resources.gceHTTPHealthChecks.my-check";
      type = types.nullOr (union types.str (resource "gce-http-health-check"));
      description = ''
        GCE HTTP Health Check resource or name of a HTTP Health Check resource not managed by NixOps.

        A member VM in this pool is considered healthy if and only if the
        specified health checks passes. Unset health check means all member
        virtual machines will be considered healthy at all times but the health
        status of this target pool will be marked as unhealthy to indicate that
        no health checks are being performed.
      '';
    };

    machines = mkOption {
      default = [];
      example = [ "machines.httpserver1" "machines.httpserver2" ];
      type = types.listOf (union types.str machine);
      description = ''
        The list of machine resources or fully-qualified GCE Node URLs to add to this pool.
      '';
    };

    serviceAccount = mkOption {
      default = "";
      example = "12345-asdf@developer.gserviceaccount.com";
      type = types.str;
      description = ''
        The GCE Service Account Email. If left empty, it defaults to the
        contents of the environment variable <envar>GCE_SERVICE_ACCOUNT</envar>.
      '';
    };

    accessKey = mkOption {
      default = "";
      example = "/path/to/secret/key.pem";
      type = types.str;
      description = ''
        The path to GCE Service Account key. If left empty, it defaults to the
        contents of the environment variable <envar>ACCESS_KEY_PATH</envar>.
      '';
    };

    project = mkOption {
      default = "";
      example = "myproject";
      type = types.str;
      description = ''
        The GCE project which should own the Target Pool. If left empty, it defaults to the
        contents of the environment variable <envar>GCE_PROJECT</envar>.
      '';
    };

  };

  config._type = "gce-target-pool";

}
