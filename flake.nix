{
  description = "Raspberry Pi USB boot utility";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        python3WithPackages = pkgs.python3.withPackages (ps: with ps; [
          # pycryptodome
          m2crypto
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Build essentials
            gnumake
            gcc
            pkg-config
            
            # USB library
            libusb1
            
            # Python with crypto packages
            python3WithPackages
            
            # Additional utilities
            xxd
            openssl
            git
            
            # For submodule management
            git
          ];

          shellHook = ''
            echo ""
            echo "🚀 Raspberry Pi usbboot development environment"
            echo ""
          '';

          # Environment variables for pkg-config to find libusb
          PKG_CONFIG_PATH = "${pkgs.libusb1.dev}/lib/pkgconfig";
          
          # Make sure the shell can find the libraries at runtime
          LD_LIBRARY_PATH = "${pkgs.libusb1}/lib";
        };

        # Optional: package the rpiboot utility itself
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "rpiboot";
          version = "0.0.1";
          
          src = ./.;
          
          nativeBuildInputs = with pkgs; [
            gnumake
            gcc
            pkg-config
          ];
          
          buildInputs = with pkgs; [
            libusb1
          ];
          
          buildPhase = ''
            make
          '';
          
          meta = with pkgs.lib; {
            description = "Raspberry Pi USB boot utility";
            homepage = "https://github.com/raspberrypi/usbboot";
            license = licenses.asl20;
            platforms = platforms.linux ++ platforms.darwin;
          };
        };
      });
}