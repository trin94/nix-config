{ lib, ... }:
{
  dirImport =
    { paths }:
    lib.filter (file: lib.hasSuffix ".nix" (toString file)) (lib.concatMap lib.fileset.toList paths);
}
