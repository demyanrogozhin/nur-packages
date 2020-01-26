{ stdenv, lib, pkgs, fetchFromGitHub, withoutWallet ? false, withZMQ ? false
, withGui ? false }:

stdenv.mkDerivation rec {
  pname = "particl-core";
  version = "0.19-git-6805257";

  src = fetchFromGitHub {
    owner = "particl";
    repo = "particl-core";
    rev = "6805257331ee9cb8f6b98dba94c15cb7d2578dfa";
    sha256 = "k4e5A3nuL6RMRDgVZBusvkc1iztsmAdiOTwdwiZlkho=";
  };

  nativeBuildInputs = with pkgs; [ pkgconfig autoreconfHook ];

  buildInputs = with pkgs;
    [ boost170 miniupnpc_2 libevent zlib unixtools.hexdump python3 ]
    ++ lib.optionals (!withoutWallet) [ db48 ]
    ++ lib.optionals (withZMQ) [ zeromq ];

  configureFlags = [
    "CFLAGS=-O2"
    "CXXFLAGS=-O2"
    "--enable-hardening"
    "--enable-upnp-default"
    "--disable-bench"
    "--with-boost-libdir=${pkgs.boost170.out}/lib"
  ] ++ lib.optionals stdenv.cc.isClang [ "CXX=clang++" "CC=clang" ]
    ++ lib.optionals (withoutWallet) [ "--disable-wallet" ]
    ++ lib.optionals (withGui) [ "--without-gui" ]
    ++ lib.optionals (!doCheck) [ "--enable-tests=no" ];

  # Try to minimize memory usage
  CXXFLAGS = "--param ggc-min-expand=1 --param ggc-min-heapsize=32768";

  # Always check during Hydra builds
  doCheck = true;
  preCheck = "patchShebangs test";

  enableParallelBuilding = false;

  meta = with lib; {
    description =
      "Privacy-Focused Marketplace & Decentralized Application Platform";
    longDescription = ''
      An open source, decentralized privacy platform built for global person to person eCommerce.
      RPC daemon and CLI client.
    '';
    homepage = "https://particl.io/";
    maintainers = with maintainers; [ demyanrogozhin ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
