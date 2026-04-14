{ stdenv, cmake, clang, cargo, rustPlatform, rustc, fetchFromGitHub, llvmPackages }:

stdenv.mkDerivation rec {
  pname = "iceoryx2";
  version = "0.8.0";
  src = fetchFromGitHub {
    owner = "eclipse-iceoryx";
    repo = "iceoryx2";
    rev = "v${version}";
    sha256 = "sha256-b/QYhV1I31vlvptMer53A86GFVhVkFEzJzaCfIQoa1k=";
  };
  patches = [ ./iceoryx2-patch.diff ];
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-6el9TdBp7m4LZzQfyEqqxezUCmBTPdvOFEzFjsSjvFE=";
  };
  nativeBuildInputs = [ cmake clang cargo rustPlatform.cargoSetupHook rustc llvmPackages.libclang ];
  LIBCLANG_PATH=''${llvmPackages.libclang.lib}/lib'';
  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];
}