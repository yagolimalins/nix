# Scaffolding CLI for new Tauri apps (`cargo create-tauri-app`).
# Not packaged in nixpkgs 26.05 — built from crates.io.
{ lib, pkgs, ... }:

pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "create-tauri-app";
  version = "4.7.3";

  src = pkgs.fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-OqvsPFLyudBagEN1PGusfwXMiQQqtPG6su/1oroeqeQ=";
  };

  cargoHash = "sha256-prpyU+gVhmbEu1qt8QHwdCE4hnt06hDSKWbfqenkWKY=";

  meta = {
    description = "Rapidly scaffold out a new Tauri app project";
    homepage = "https://github.com/tauri-apps/create-tauri-app";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "cargo-create-tauri-app";
  };
})
