{
  description = "leJOS, Java for LEGO Mindstorms";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-jdk = {
      url = "github:NixOS/nixpkgs/18.03";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-jdk, systems, ... }@inputs : let
    inherit (nixpkgs) lib;
    eachSystem = lib.genAttrs (import systems);
    pkgsFor = eachSystem (system: nixpkgs.legacyPackages.${system});
    jdkFor = eachSystem (system: (import inputs.nixpkgs-jdk { inherit system; }));
  in {
    packages = eachSystem (system: let
      pkgs = pkgsFor.${system};
      jdk = jdkFor.${system}.jdk7.overrideAttrs (prevAttrs: {
        DISABLE_HOTSPOT_OS_VERSION_CHECK = "ok";
        preFixup = prevAttrs.preFixup + ''
          cat <<EOF > $out/nix-support/setup-hook
          if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out/lib/openjdk; fi
          EOF
        '';
      });
      ant = pkgs.ant.overrideAttrs (prevAttrs: rec {
        version = "1.9.16";

        src = pkgs.fetchurl {
          url = "mirror://apache/ant/binaries/apache-ant-${version}-bin.tar.bz2";
          sha256 = "0rif9kj6njajy951w3aapk27y1mbaxb08whs126v533h96rb1kjp";
        };

        contrib = pkgs.fetchurl {
          url = "mirror://sourceforge/ant-contrib/ant-contrib-1.0b3-bin.tar.bz2";
          sha256 = "96effcca2581c1ab42a4828c770b48d54852edf9e71cefc9ed2ffd6590571ad1";
        };
      });
    in builtins.mapAttrs (name: value: pkgs.callPackage ./packages/${name} value) {
      lejos-nxj = { inherit jdk; inherit ant; };
    });

    devShells = eachSystem (system: let
      pkgs = pkgsFor.${system};
    in (lib.attrsets.mergeAttrsList (builtins.map (name: let
      lejos = self.packages.${system}.${name};
    in {
      ${name} = pkgs.mkShell {
        name = "${name}-shell";
        buildInputs = with pkgs; [
          jre
          jdt-language-server
        ] ++ [
          lejos
        ];
        shellHook = ''
          cat <<EOF > pom.xml
          <project>
            <modelVersion>4.0.0</modelVersion>
            <groupId>${name}-project</groupId>
            <artifactId>${name}-project</artifactId>
            <version>1</version>
            <dependencies>
              <dependency>
               <groupId>${name}</groupId>
               <artifactId>${name}</artifactId>
               <scope>system</scope>
               <version>1</version>
               <systemPath>${lejos}/lib/nxt/classes.jar</systemPath>
              </dependency>
            </dependencies>
          </project>
          EOF
          . ./packages/${name}/utils.sh
        '';
      };
    }) [
      "lejos-nxj"
    ])));
  };
}
