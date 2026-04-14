{ stdenv, cmake, clang, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "bdwgc";
  version = "8.2.12";
  src = fetchFromGitHub {
    owner = "ivmai";
    repo = "bdwgc";
    rev = "v8.2.12";
    sha256 = "sha256-5yeAB5Y92YjOutwRXBJkMxoOLkmzmqIJs4PirKX89fE=";
  };
  nativeBuildInputs = [ cmake clang ];
  cmakeFlags = [
    "-Denable_cplusplus=ON"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
  ];
}