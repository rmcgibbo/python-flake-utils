{
  description = "Utility for making composable python flakes";

  outputs = { self }:
    let
      mkPythonOverlay = func:
        (final: prev:
          let
            composeOverlays =
              prev.lib.foldl' prev.lib.composeExtensions (self: super: { });
          in
          {
            # cc https://github.com/NixOS/nixpkgs/issues/44426
            python38PackagesOverrides = (prev.python38PackagesOverrides or [ ]) ++ [
              (pythonSelf: pythonSuper: (func pythonSuper))
            ];
            python39PackagesOverrides = (prev.python39PackagesOverrides or [ ]) ++ [
              (pythonSelf: pythonSuper: (func pythonSuper))
            ];
            python310PackagesOverrides = (prev.python310PackagesOverrides or [ ]) ++ [
              (pythonSelf: pythonSuper: (func pythonSuper))
            ];

            python38 = prev.python38.override {
              packageOverrides = composeOverlays final.python38PackagesOverrides;
            };
            python39 = prev.python39.override {
              packageOverrides = composeOverlays final.python39PackagesOverrides;
            };
            python310 = prev.python310.override {
              packageOverrides = composeOverlays final.python310PackagesOverrides;
            };
          });
    in
    {
      lib = {
        inherit mkPythonOverlay;
      };
    };
}
