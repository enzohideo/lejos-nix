{
  description = "leJOS, Java for LEGO Mindstorms";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
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
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
          mkLejosShell =
            name:
            let
              lejos = self.packages.${system}.${name};
            in
            pkgs.mkShell {
              inherit name;
              buildInputs = [ lejos ];
              NXJ_HOME = lejos;
            };
        in
        {
          default = self.devShells.${system}.lejos-nxj;
          lejos-nxj = mkLejosShell "lejos-nxj";
          lejos-nxj-src = mkLejosShell "lejos-nxj-src";
        }
      );
    };
}
