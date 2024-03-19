{ pkgs, lib, ... }:
let frameworks = pkgs.darwin.apple_sdk.frameworks;
in {
  env.CFLAGS = lib.mkForce ("-I${pkgs.darwin.libobjc}/include/");

  # https://devenv.sh/packages/
  packages = with pkgs; [
    ninja
    python3
    cmake
    gcc
    darwin.libobjc
    # darwin.libiconv
    frameworks.Security
    frameworks.CoreServices
    frameworks.CoreFoundation
    frameworks.AppKit
    frameworks.Foundation
    frameworks.ApplicationServices
    frameworks.CoreGraphics
    frameworks.CoreVideo
    frameworks.Carbon
    frameworks.IOKit
    frameworks.CoreAudio
    frameworks.AudioUnit
    frameworks.QuartzCore
    frameworks.Metal
  ];
}