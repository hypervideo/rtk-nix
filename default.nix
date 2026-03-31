{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

let
  version = "0.34.2";
in
rustPlatform.buildRustPackage rec {
  pname = "rtk";
  inherit version;

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    rev = "v${version}";
    hash = "sha256-oBaF3BdF4h7meP7+8gtqBSgOFn0wQq08bOkygpn/ukg=";
  };

  cargoLock = {
    lockFile = src + "/Cargo.lock";
  };

  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    version_output="$($out/bin/rtk --version)"
    if [ "$version_output" != "rtk ${version}" ]; then
      echo "unexpected version output: $version_output"
      exit 1
    fi
  '';

  meta = with lib; {
    description = "High-performance CLI proxy to minimize LLM token consumption";
    homepage = "https://github.com/rtk-ai/rtk";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "rtk";
  };
}
