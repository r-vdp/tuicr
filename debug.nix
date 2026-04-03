# Standalone build of the instrumented tuicr from this branch.
# Logs per-frame byte counts to ~/.cache/tuicr/frame.log.
#
#   nix build github:r-vdp/tuicr/rvdp/render-perf-debug#debug
#
# All inputs are fetched from the network; no local files needed.
{
  rustPlatform,
  pkg-config,
  libgit2,
}:
rustPlatform.buildRustPackage {
  pname = "tuicr-debug";
  version = "0.9.0";

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libgit2 ];

  # Add Terminal::scroll_region to the vendored ratatui-core and drop the
  # weak ratatui-termion reference so the offline resolver does not need it.
  postPatch = ''
    patch --directory "$cargoDepsCopy"/ratatui-core-*/ \
      --strip 1 < vendor-patches/ratatui-core-terminal-scroll-region.patch
    sed --in-place '/ratatui-termion?\/scrolling-regions/d' \
      "$cargoDepsCopy"/ratatui-0.30.*/Cargo.toml
  '';

  doCheck = false;

  meta.mainProgram = "tuicr";
}
