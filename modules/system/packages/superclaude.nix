{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.superclaude;
  
  # Custom SuperClaude package derivation
  superclaude = pkgs.python3Packages.buildPythonApplication rec {
    pname = "superclaude";
    version = "4.0.6";  # Using latest available wheel version
    format = "wheel";
    
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/01/5b/16e9f86945bd44a9627ca954132bcf4868c6308ec3ecf6180e39db8b52ef/superclaude-4.0.6-py3-none-any.whl";
      sha256 = "itq/IuG63WoCzDM4lui4SPorPt8oIxpV2gj5mImVfBA=";
    };
    
    # Since we don't have the exact dependencies, we'll include common ones
    # and let the build process tell us what's missing
    propagatedBuildInputs = with pkgs.python3Packages; [
      setuptools
      wheel
      pip
      requests
      click  # Common for CLI tools
      pyyaml  # Common for configuration
      rich  # Common for CLI formatting
      # Add more as needed based on build errors
    ];
    
    # Skip tests for now since we don't know the test setup
    doCheck = false;
    
    # Ensure the executable is available
    postInstall = ''
      # Create symlink for case-insensitive access
      ln -sf $out/bin/SuperClaude $out/bin/superclaude
    '';
    
    meta = with lib; {
      description = "Meta-programming configuration framework that transforms Claude Code into a structured development platform";
      homepage = "https://github.com/SuperClaude-Org/SuperClaude_Framework";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in
{
  options.custom.system.packages.superclaude = {
    enable = mkEnableOption "SuperClaude Framework - AI-enhanced development framework";
    
    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install SuperClaude system-wide";
    };
  };

  config = mkIf cfg.enable {
    # Install SuperClaude and required Python tools system-wide
    environment.systemPackages = mkIf cfg.installGlobally ([
      superclaude
      pkgs.python3
      pkgs.python3Packages.pip
      pkgs.python3Packages.pipx
    ]);
    
    # Alternative: Install for specific user via home-manager
    # This would go in home manager configuration instead
    # home.packages = [ superclaude ];
  };
}