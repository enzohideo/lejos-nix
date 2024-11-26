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
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
          jdk = pkgs.jdk8;
          mkLejosShell = (
            name:
            let
              lejos = self.packages.${system}.${name};
              shellHook = builtins.readFile ./packages/${name}/shellHook.sh;
            in
            pkgs.mkShell {
              name = "${name}-shell";
              buildInputs = [
                lejos
              ];
              NXJ_HOME = lejos;
              LEJOS_NXT_JAVA_HOME = "${jdk}/lib/openjdk";
              inherit shellHook;
            }
          );
        in
        {
          default = self.devShells.${system}.lejos-nxj;
          lejos-nxj = mkLejosShell "lejos-nxj";
        }
      );
    };
}
