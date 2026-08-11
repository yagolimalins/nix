# wasm-bindgen-cli 0.2.127 — not yet in nixpkgs 26.05 (stops at 0.2.126).
# Required by current Dioxus / wasm-bindgen crate pins.
{ pkgs, ... }:

pkgs.buildWasmBindgenCli rec {
  src = pkgs.fetchCrate {
    pname = "wasm-bindgen-cli";
    version = "0.2.127";
    hash = "sha256-di+qBAdd7pENLiIB9CoZoab+W5xeDoByMREcCGTSzWo=";
  };

  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    inherit src;
    inherit (src) pname version;
    hash = "sha256-FTv2GZIAQs0ePdIZXIXil7JbZ6kIT05VG6vqC1qNFxQ=";
  };
}
