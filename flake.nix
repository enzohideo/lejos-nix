{
  description = "leJOS, Java for LEGO Mindstorms";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);
      pkgsFor = eachSystem (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
          jdk = pkgs.jdk8;
        in
        builtins.mapAttrs (name: value: pkgs.callPackage ./packages/${name} value) {
          lejos-nxj = {
            inherit jdk;
          };
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
          jdk = pkgs.jdk8;
        in
        (lib.attrsets.mergeAttrsList (
          builtins.map (
            name:
            let
              lejos = self.packages.${system}.${name};
              utils = builtins.readFile ./packages/${name}/utils.sh;
            in
            {
              ${name} = pkgs.mkShell {
                name = "${name}-shell";
                buildInputs = [
                  lejos
                ];
                NXJ_HOME = "${lejos}/lib";
                LEJOS_NXT_JAVA_HOME = "${jdk}/lib/openjdk";
                shellHook = utils;
              };
              "${name}-jdt" =
                let
                  pom = ''
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
                    </project>'';
                in
                pkgs.mkShell {
                  name = "${name}-jdt-shell";
                  buildInputs = [
                    lejos
                    pkgs.jdt-language-server
                  ];
                  shellHook = ''
                    cat <<EOF > pom.sample.xml
                    ${pom}
                    EOF
                    ${utils}
                  '';
                };
            }
          ) [ "lejos-nxj" ]
        ))
      );
    };
}
