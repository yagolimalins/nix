# dioxus-cli matching current Dioxus 0.7.10 + wasm-bindgen 0.2.126.
# nixpkgs 26.05 still ships dx 0.7.9 with an older wasm-bindgen-cli on PATH.
{
  lib,
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dioxus-cli";
  version = "0.7.10";

  src = pkgs.fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-kPzo5zRSVs46SjiDRKpKxca8kPcWUgqc/LMKQsk0sC8=";
  };

  cargoHash = "sha256-cvBVIkIqBjXFifYNpL2DqZpQcBaX/59Xw0ZJKUvUcIs=";

  buildFeatures = [
    "no-downloads"
    "disable-telemetry"
  ];

  env.OPENSSL_NO_VENDOR = 1;

  nativeBuildInputs = with pkgs; [
    pkg-config
    cacert
    makeWrapper
  ];

  buildInputs = [ pkgs.openssl ];

  # Network / monorepo tests — skip like nixpkgs.
  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/dx \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.esbuild
          pkgs.wasm-bindgen-cli_0_2_126
        ]
      }
  '';

  meta = {
    description = "CLI for building fullstack web, desktop, and mobile apps with Dioxus";
    homepage = "https://dioxus.dev";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "dx";
  };
})
