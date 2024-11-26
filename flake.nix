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
    }:
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
        {
          lejos-nxj = pkgs.callPackage ./packages/lejos-nxj {
            inherit jdk;
          };
          lejos-nxj-src = pkgs.callPackage ./packages/lejos-nxj-src {
            inherit jdk;
          };
          lejos-ev3 = pkgs.callPackage ./packages/lejos-ev3 {};
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
          jdk = pkgs.jdk8;
        in
        {
          default = self.devShells.${system}.lejos-nxj;
          lejos-nxj =
            let
              name = "lejos-nxj";
              lejos = self.packages.${system}.lejos-nxj;
            in
            pkgs.mkShell {
              inherit name;
              buildInputs = [
                lejos
              ];
              NXJ_HOME = lejos;
              LEJOS_NXT_JAVA_HOME = "${jdk}/lib/openjdk";
              shellHook = builtins.readFile ./packages/${name}/shellHook.sh;
            };
        }
      );
    };
}
