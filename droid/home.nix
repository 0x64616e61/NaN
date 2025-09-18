{ config, lib, pkgs, ... }:

{
  # Read the changelog before changing this value
  home.stateVersion = "24.05";

  # Git configuration (matching your desktop)
  programs.git = {
    enable = true;
    userName = "a";
    userEmail = "mini@nix";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      push.default = "current";
      pull.rebase = false;
    };
  };

  # Zsh configuration with enhanced features
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "sudo" "git" "docker" "kubectl" ];
    };

    initExtra = ''
      # Set default editor
      export EDITOR=nvim
      export VISUAL=nvim

      # Ensure SHELL is set for Claude
      export SHELL=${pkgs.bash}/bin/bash

      # Panic rollback function (adapted for Nix-on-Droid)
      panic() {
        cd ~/nix-modules 2>/dev/null || cd ~
        echo "[!] PANIC MODE - Rolling back local changes..."
        git fetch origin && git reset --hard origin/main
        echo "[*] Reset complete - local changes discarded"
      }

      # Create A! pattern aliases (matching your desktop)
      for i in {1..20}; do
        A=$(printf 'A%.0s' $(seq 1 $i))
        alias "$A!"="panic"
      done

      # Enable vi mode
      bindkey -v

      # Better history
      HISTSIZE=10000
      SAVEHIST=10000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS

      # Directory navigation
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS

      # Completion
      autoload -Uz compinit && compinit
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      # FZF integration if available
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

      # Zoxide init if available
      command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

      # Fuzzy search functions
      _fuzzy_change_directory() {
        local initial_query="$1"
        local selected_dir
        local fzf_options=('--preview=ls -p {}' '--preview-window=right:60%')
        fzf_options+=(--height "80%" --layout=reverse --preview-window right:60% --cycle)
        local max_depth=7

        if [[ -n "$initial_query" ]]; then
          fzf_options+=("--query=$initial_query")
        fi

        selected_dir=$(find . -maxdepth $max_depth \( -name .git -o -name node_modules -o -name .venv -o -name target -o -name .cache \) -prune -o -type d -print 2>/dev/null | fzf "''${fzf_options[@]}")

        if [[ -n "$selected_dir" && -d "$selected_dir" ]]; then
          cd "$selected_dir" || return 1
        else
          return 1
        fi
      }

      _fuzzy_edit_search_file_content() {
        local selected_file
        selected_file=$(grep -irl "''${1:-}" ./ | fzf --height "80%" --layout=reverse --preview-window right:60% --cycle --preview 'cat {}' --preview-window right:60%)

        if [[ -n "$selected_file" ]]; then
          if command -v "$EDITOR" &>/dev/null; then
            "$EDITOR" "$selected_file"
          else
            echo "EDITOR is not specified. using vim."
            vim "$selected_file"
          fi
        else
          echo "No file selected or search returned no results."
        fi
      }

      _fuzzy_edit_search_file() {
        local initial_query="$1"
        local selected_file
        local fzf_options=()
        fzf_options+=(--height "80%" --layout=reverse --preview-window right:60% --cycle)
        local max_depth=5

        if [[ -n "$initial_query" ]]; then
          fzf_options+=("--query=$initial_query")
        fi

        selected_file=$(find . -maxdepth $max_depth -type f 2>/dev/null | fzf "''${fzf_options[@]}")

        if [[ -n "$selected_file" && -f "$selected_file" ]]; then
          if command -v "$EDITOR" &>/dev/null; then
            "$EDITOR" "$selected_file"
          else
            echo "EDITOR is not specified. using vim."
            vim "$selected_file"
          fi
        else
          return 1
        fi
      }

      _df() {
        if [[ $# -ge 1 && -e "''${@: -1}" ]]; then
          duf "''${@: -1}"
        else
          duf
        fi
      }

      # Starship prompt
      eval "$(${pkgs.starship}/bin/starship init zsh)"

      # Fastfetch on startup
      fastfetch --logo none
    '';

    shellAliases = {
      # Git aliases
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";
      gd = "git diff";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      "...." = "cd ../../..";

      # Common commands
      ll = "eza -la";
      la = "eza -a";
      l = "eza -l";
      tree = "eza --tree";
      ls = "eza";

      # System
      vim = "nvim";
      vi = "nvim";
      cat = "bat";
      c = "clear";
      vc = "code";
      mkdir = "mkdir -p";

      # Fuzzy search aliases
      ffec = "_fuzzy_edit_search_file_content";
      ffcd = "_fuzzy_change_directory";
      ffe = "_fuzzy_edit_search_file";
      df = "_df";

      # Clipboard (if termux-api is available)
      pbcopy = "termux-clipboard-set 2>/dev/null || echo 'termux-api not installed'";
      pbpaste = "termux-clipboard-get 2>/dev/null || echo 'termux-api not installed'";

      # Quick edits
      zshrc = "nvim ~/.zshrc";
      reload = "source ~/.zshrc";

      # Process management
      psg = "ps aux | grep -v grep | grep -i";

      # Network
      myip = "curl -s ifconfig.me";

      # Task management (if you install task-master)
      tm = "task-master 2>/dev/null || echo 'task-master not installed'";

      # Music player (suppress non-critical errors)
      music = "ncmpcpp 2>/dev/null";
      tidal = "ncmpcpp 2>/dev/null";  # Alias for Tidal via mopidy

      # Quick update command (adapted for Nix-on-Droid)
      "update!" = ''
        cd ~/nix-modules 2>/dev/null || cd ~ && \
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then \
          echo "[+] Committing changes..." && \
          git add -A && \
          git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')" && \
          echo "[>] Pushing to GitHub..." && \
          git push origin main 2>/dev/null || echo "[!] Push failed - check git credentials"; \
        fi && \
        echo "[*] Rebuilding Nix-on-Droid..." && \
        nix-on-droid switch --flake .
      '';

      # Work summary using available tools
      worksummary = ''
        cd ~/nix-modules 2>/dev/null || cd ~ && \
        echo "Creating work summary..." && \
        git log --since="12 hours ago" --oneline
      '';

      # Claude code alias
      cc = "claude";  # Alias for claude-code
    };
  };

  # Neovim configuration (basic but functional)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set wrap
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch
      set termguicolors
      set scrolloff=8
      set signcolumn=yes
      set updatetime=50
      set cursorline

      " Enable mouse
      set mouse=a

      " Leader key
      let mapleader = " "

      " Basic keymaps
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>/ :noh<CR>

      " Better navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Catppuccin Mocha colors
      hi Normal guibg=#1E1E2E guifg=#CDD6F4
      hi CursorLine guibg=#313244
      hi LineNr guifg=#6C7086
      hi CursorLineNr guifg=#94E2D5
    '';
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;

    extraConfig = ''
      # Set prefix to Ctrl-a
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # Reload config
      bind r source-file ~/.tmux.conf

      # Fast pane switching
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D

      # Don't rename windows automatically
      set-option -g allow-rename off

      # Catppuccin Mocha colors
      set -g status-bg "#1E1E2E"
      set -g status-fg "#CDD6F4"

      # Status bar
      set -g status-left "#[fg=#94E2D5,bold] #S "
      set -g status-right "#[fg=#F9E2AF] %Y-%m-%d %H:%M "
      set -g status-left-length 30
    '';
  };

  # SSH client configuration
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
        ServerAliveInterval 60
        ServerAliveCountMax 3
    '';
  };

  # Btop configuration (matching your desktop)
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";  # Will use Catppuccin if available
      theme_background = false;
      vim_keys = true;
      update_ms = 1000;
      proc_sorting = "cpu lazy";
      proc_tree = false;
      proc_per_core = true;
      proc_mem_bytes = true;
      cpu_graph_upper = "total";
      cpu_graph_lower = "total";
      show_disks = true;
      show_swap = true;
      show_uptime = true;
      mem_graphs = true;
      net_sync = true;
    };
  };

  # Bat configuration (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      style = "numbers,changes,header";
    };
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    ];
  };

  # Zoxide (smart cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    LESS = "-R";

    # Shell for Claude and other tools
    SHELL = "${pkgs.bash}/bin/bash";

    # For better compatibility
    TERM = "xterm-256color";
    COLORTERM = "truecolor";

    # Locale settings
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # Additional packages for home environment
  home.packages = with pkgs; [
    # System utilities
    busybox

    # Python with packages (avoids collision)
    (python3.withPackages (ps: with ps; [
      pip
      setuptools
      wheel
      requests
      click
      pyyaml
      rich
    ]))

    # Shell enhancements
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-powerlevel10k
    starship
    fastfetch
    duf

    # CLI power tools
    parallel
    imagemagick
    envsubst
    trash-cli
    gawk
    cava
    cliphist
    coreutils
    bash-completion

    # Developer tools
    direnv
    nix-direnv
    commitlint
    nix-index
    comma

    # Additional CLI tools
    signal-cli
    netcat  # For network checks

    # Audio tools for direct Android playback
    sox  # Play audio directly
    ffmpeg  # Audio/video processing
    alsa-utils  # ALSA utilities

    # Music streaming and players
    # Install the packages directly
    mopidy
    mopidy-mpd
    mopidy-tidal
    mopidy-iris  # Web interface for Mopidy
    python3Packages.tidalapi  # Required dependency for mopidy-tidal
    python3Packages.isodate  # Required by tidalapi
    python3Packages.mpegdash  # Required by tidalapi
    python3Packages.python-dateutil  # Required by tidalapi
    python3Packages.six  # Required by isodate
    python3Packages.typing-extensions  # Required by tidalapi
    python3Packages.ratelimit  # Required by tidalapi for API rate limiting
    # Note: setuptools, requests, urllib3, certifi, charset-normalizer, idna
    # are already included in the Python environment above or as dependencies

    # Task management tools
    nodejs

    # Mopidy wrapper that sets up Python paths correctly
    (writeScriptBin "mopidy-with-extensions" ''
      #!${bash}/bin/bash

      # Set up Python path with all extensions and dependencies
      DEPS="${pkgs.python3Packages.setuptools}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.six}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.typing-extensions}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.isodate}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.mpegdash}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.python-dateutil}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.requests}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.ratelimit}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.urllib3}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.certifi}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.charset-normalizer}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.idna}/lib/python3.11/site-packages"
      DEPS="$DEPS:${pkgs.python3Packages.tidalapi}/lib/python3.11/site-packages"

      MOPIDY="${pkgs.mopidy-tidal}/lib/python3.11/site-packages"
      MOPIDY="$MOPIDY:${pkgs.mopidy-mpd}/lib/python3.11/site-packages"
      MOPIDY="$MOPIDY:${pkgs.mopidy-iris}/lib/python3.11/site-packages"
      MOPIDY="$MOPIDY:${pkgs.mopidy}/lib/python3.11/site-packages"

      export PYTHONPATH="$DEPS:$MOPIDY''${PYTHONPATH:+:$PYTHONPATH}"

      # Set up OAuth token path for mopidy-tidal
      export TIDAL_OAUTH_TOKEN_PATH="$HOME/.local/share/mopidy/tidal_oauth_token.json"

      # Show debug info if requested
      if [ "$1" = "--debug-paths" ]; then
        echo "PYTHONPATH entries:"
        echo "$PYTHONPATH" | tr ':' '\n' | while read -r path; do
          [ -n "$path" ] && echo "  - $path"
        done
        echo ""
        echo "Checking for mopidy_tidal module..."
        ${pkgs.python3}/bin/python -c "import sys; sys.path = '$PYTHONPATH'.split(':') + sys.path; import mopidy_tidal; print(f'Found: {mopidy_tidal.__file__}')" 2>&1

        echo ""
        echo "OAuth token status:"
        if [ -f "$TIDAL_OAUTH_TOKEN_PATH" ]; then
          echo "  ✓ Token file exists: $TIDAL_OAUTH_TOKEN_PATH"
        else
          echo "  ✗ No token file found. Run: mopidy-tidal-auth"
        fi
        exit 0
      fi

      # Run mopidy with the environment
      exec ${pkgs.mopidy}/bin/mopidy "$@"
    '')

    # Mopidy service starter script
    (writeScriptBin "mopidy-start" ''
      #!${bash}/bin/bash
      echo "Starting Mopidy with Tidal support..."
      mkdir -p ~/.config/mopidy
      mkdir -p ~/.cache/mopidy
      mkdir -p ~/.local/share/mopidy

      # Check if config exists
      if [ ! -f ~/.config/mopidy/mopidy.conf ]; then
        echo "No configuration found. Running mopidy-setup first..."
        mopidy-setup
        echo ""
        echo "Please edit ~/.config/mopidy/mopidy.conf and add your Tidal credentials"
        exit 1
      fi

      # Run mopidy with extensions
      exec mopidy-with-extensions --config ~/.config/mopidy/mopidy.conf
    '')

    # Start mopidy in background
    (writeScriptBin "mopidy-bg" ''
      #!${bash}/bin/bash
      # Check if already running - look for any mopidy process
      if ps aux | grep "mopidy" | grep -v grep | grep -v "mopidy-bg" | grep -v "mopidy-stop" | grep -v "mopidy-status" > /dev/null 2>&1; then
        echo "Mopidy is already running. Use 'mopidy-stop' to stop it first."
        exit 1
      fi

      echo "Starting Mopidy in background..."
      mkdir -p ~/.config/mopidy
      mkdir -p ~/.cache/mopidy
      mkdir -p ~/.local/share/mopidy
      mkdir -p ~/.local/share/mopidy/logs

      # Start in background with logging
      nohup mopidy-with-extensions --config ~/.config/mopidy/mopidy.conf \
        > ~/.local/share/mopidy/logs/mopidy.log 2>&1 &

      echo "Mopidy started with PID $!"
      echo "Logs: ~/.local/share/mopidy/logs/mopidy.log"
      echo "Use 'mopidy-status' to check status"
      echo "Use 'mopidy-stop' to stop"
    '')

    # Stop mopidy
    (writeScriptBin "mopidy-stop" ''
      #!${bash}/bin/bash
      echo "Stopping Mopidy..."

      # Find all mopidy processes (including wrapped ones)
      PIDS=$(ps aux | grep "mopidy" | grep -v grep | grep -v "mopidy-stop" | grep -v "mopidy-status" | awk '{print $2}')

      if [ -n "$PIDS" ]; then
        echo "Found mopidy processes: $PIDS"

        # First try graceful shutdown
        for pid in $PIDS; do
          kill $pid 2>/dev/null
        done

        echo "Waiting for graceful shutdown..."
        sleep 2

        # Check if any still running and force kill
        REMAINING=$(ps aux | grep "mopidy" | grep -v grep | grep -v "mopidy-stop" | grep -v "mopidy-status" | awk '{print $2}')
        if [ -n "$REMAINING" ]; then
          echo "Force killing remaining processes: $REMAINING"
          for pid in $REMAINING; do
            kill -9 $pid 2>/dev/null
          done
        fi

        echo "All mopidy processes stopped"
      else
        echo "No mopidy processes found"
      fi
    '')

    # Check mopidy status
    (writeScriptBin "mopidy-status" ''
      #!${bash}/bin/bash
      if ps aux | grep -v grep | grep -q "mopidy"; then
        echo "✓ Mopidy is running"
        echo ""
        echo "Process details:"
        ps aux | grep "mopidy" | grep -v grep | grep -v mopidy-status
        echo ""

        # Check if MPD port is listening
        if ${pkgs.netcat}/bin/nc -z 127.0.0.1 6600 2>/dev/null; then
          echo "✓ MPD interface is available on port 6600"
          echo "  Connect with: ncmpcpp"
        else
          echo "⚠ MPD interface is not responding on port 6600"
        fi
      else
        echo "✗ Mopidy is not running"
        echo "  Start with: mopidy-bg (background) or mopidy-start (foreground)"
      fi
    '')

    # View mopidy logs
    (writeScriptBin "mopidy-logs" ''
      #!${bash}/bin/bash
      LOG_FILE=~/.local/share/mopidy/logs/mopidy.log

      if [ -f "$LOG_FILE" ]; then
        echo "=== Mopidy Logs ==="
        tail -n 50 "$LOG_FILE"
        echo ""
        echo "Full log: $LOG_FILE"
      else
        echo "No log file found. Start mopidy with 'mopidy-bg' to create logs."
      fi
    '')

    # Restart mopidy
    (writeScriptBin "mopidy-restart" ''
      #!${bash}/bin/bash
      echo "Restarting Mopidy..."
      mopidy-stop
      sleep 2
      mopidy-bg
    '')

    # Audio Share server setup script
    (writeScriptBin "audio-share-setup" ''
      #!${bash}/bin/bash
      echo "Setting up Audio Share server..."

      # Download Audio Share server for Linux
      mkdir -p ~/.local/bin
      cd ~/.local/bin

      if [ ! -f "as-cmd" ]; then
        echo "Downloading Audio Share server..."
        wget -q https://github.com/mkckr0/audio-share/releases/latest/download/audio-share-server-cmd-linux.tar.gz
        tar -xzf audio-share-server-cmd-linux.tar.gz
        chmod +x as-cmd
        rm audio-share-server-cmd-linux.tar.gz
      fi

      # Create PulseAudio virtual sink
      ${pkgs.pulseaudio}/bin/pactl load-module module-null-sink sink_name=audioshare_sink sink_properties=device.description="AudioShare"

      echo "✓ Audio Share server ready"
      echo ""
      echo "To start streaming:"
      echo "1. Run: audio-share-start"
      echo "2. Install 'Audio Share' from F-Droid"
      echo "3. Connect to this device's IP on port 65530"
    '')

    # Get device IP address
    (writeScriptBin "get-ip" ''
      #!${bash}/bin/bash
      echo "Finding your IP address..."

      # Method 1: Parse from /proc/net (no permissions needed)
      IP=$(cat /proc/net/fib_trie 2>/dev/null | grep -oP '192\.168\.\d+\.\d+|10\.\d+\.\d+\.\d+' | grep -v "\.255" | grep -v "\.0$" | head -1)

      # Method 2: Try getprop (Android specific)
      if [ -z "$IP" ]; then
        IP=$(getprop dhcp.wlan0.ipaddress 2>/dev/null)
      fi

      if [ -n "$IP" ]; then
        echo "Your IP address: $IP"
      else
        echo "Could not determine IP automatically."
        echo ""
        echo "Find it manually:"
        echo "1. Go to Settings → WiFi"
        echo "2. Tap on your connected network"
        echo "3. Look for 'IP address'"
        echo ""
        echo "It will be something like 192.168.1.xxx"
      fi
    '')

    # Start Audio Share server
    (writeScriptBin "audio-share-start" ''
      #!${bash}/bin/bash
      # Start PulseAudio if needed
      if ! ${pkgs.pulseaudio}/bin/pactl info >/dev/null 2>&1; then
        ${pkgs.pulseaudio}/bin/pulseaudio --start --exit-idle-time=-1
        sleep 2
      fi

      # Get local IP
      IP=$(cat /proc/net/fib_trie 2>/dev/null | grep -oP '192\.168\.\d+\.\d+|10\.\d+\.\d+\.\d+' | grep -v "\.255" | grep -v "\.0$" | head -1)

      if [ -z "$IP" ]; then
        echo "Enter your device IP manually (check WiFi settings):"
        read IP
      fi

      echo "Starting Audio Share server..."
      echo "Connect Audio Share app to: $IP:65530"

      # Start server with PulseAudio monitor
      ~/.local/bin/as-cmd -h $IP -p 65530 --encoding ENCODING_PCM_16BIT --channels 2 --sample-rate 44100
    '')

    # Simple audio start for MPV
    (writeScriptBin "audio-mpv" ''
      #!${bash}/bin/bash
      echo "═══════════════════════════════════════════════════════"
      echo "    Tidal LOSSLESS Audio - Direct to Phone Speakers"
      echo "═══════════════════════════════════════════════════════"
      echo ""
      echo "🎵 Simple 3-Step Setup:"
      echo ""
      echo "1. Start Mopidy (this terminal):"
      echo "   $ mopidy-bg"
      echo ""
      echo "2. Open new terminal and run:"
      echo "   $ mpv-audio"
      echo ""
      echo "3. Open third terminal for control:"
      echo "   $ ncmpcpp"
      echo "   - Press 4: Search"
      echo "   - Press Enter: Add song"
      echo "   - Press p: Play"
      echo ""
      echo "💯 Audio Quality:"
      echo "   Tidal LOSSLESS → Direct HTTP → MPV → Phone Speakers"
      echo "   No quality loss, perfect CD quality!"
      echo "═══════════════════════════════════════════════════════"
    '')

    # Start PulseAudio for network streaming (optimized for GrapheneOS)
    (writeScriptBin "audio-start" ''
      #!${bash}/bin/bash
      echo "═══════════════════════════════════════════════════════"
      echo "       Tidal Audio Streaming for GrapheneOS"
      echo "═══════════════════════════════════════════════════════"

      # Create PulseAudio config directory
      mkdir -p ~/.config/pulse

      # Create daemon.conf with optimized settings
      cat > ~/.config/pulse/daemon.conf <<EOF
exit-idle-time = -1
flat-volumes = no
default-sample-rate = 44100
default-sample-channels = 2
resample-method = speex-float-5
default-fragments = 4
default-fragment-size-msec = 25
EOF

      # Create default.pa with Simple Protocol TCP streaming
      cat > ~/.config/pulse/default.pa <<EOF
.include ${pkgs.pulseaudio}/etc/pulse/default.pa
load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1;192.168.0.0/16;10.0.0.0/8 auth-anonymous=1 port=4713
load-module module-simple-protocol-tcp rate=44100 format=s16le channels=2 port=12345 record=false playback=true listen=0.0.0.0
EOF

      # Kill any existing PulseAudio
      ${pkgs.pulseaudio}/bin/pulseaudio --kill 2>/dev/null

      # Start PulseAudio
      echo "[*] Starting high-quality audio stream..."
      HOME=$HOME ${pkgs.pulseaudio}/bin/pulseaudio --start --exit-idle-time=-1

      sleep 2

      if ${pkgs.pulseaudio}/bin/pactl info >/dev/null 2>&1; then
        # Ensure module is loaded
        MODULE_ID=$(${pkgs.pulseaudio}/bin/pactl load-module module-simple-protocol-tcp \
          rate=44100 format=s16le channels=2 port=12345 \
          record=false playback=true listen=0.0.0.0 2>/dev/null) || {
          echo "[!] Module may already be loaded"
          MODULE_ID=$(${pkgs.pulseaudio}/bin/pactl list modules short | grep simple-protocol-tcp | awk '{print $1}' | head -1)
        }

        # Get IP address
        IP=$(get-ip)

        echo ""
        echo "✅ Audio server ready! (Module ID: $MODULE_ID)"
        echo "───────────────────────────────────────────────────────"
        echo ""
        echo "📱 Simple Protocol Player Setup:"
        echo ""
        echo "1. Download APK (ARM64):"
        echo "   https://github.com/kaytat/SimpleProtocolPlayer/releases"
        echo ""
        echo "2. App Configuration:"
        echo "   • Server: $IP"
        echo "   • Port: 12345"
        echo "   • Sample Rate: 44100 Hz"
        echo "   • Audio Format: 16-bit PCM"
        echo "   • Channels: Stereo"
        echo "   • Buffer: 100-200ms (adjust for latency)"
        echo ""
        echo "3. Start playing:"
        echo "   • Run: mopidy-bg"
        echo "   • Open: ncmpcpp or music"
        echo "   • Press: 2 (browse), 4 (search)"
        echo ""
        echo "───────────────────────────────────────────────────────"
        echo "💡 Tips:"
        echo "  • Keep phone and terminal on same WiFi"
        echo "  • Audio quality: CD (16-bit/44.1kHz)"
        echo "  • Use audio-check to test connection"
        echo "  • Run audio-stop when done"
        echo "═══════════════════════════════════════════════════════"
      else
        echo "✗ Failed to start PulseAudio"
        echo "Check logs: journalctl -xe --user"
      fi
    '')


    # Check audio streaming status
    (writeScriptBin "audio-check" ''
      #!${bash}/bin/bash
      echo "Checking audio streaming status..."
      echo ""

      # Check PulseAudio daemon
      if ${pkgs.pulseaudio}/bin/pactl info >/dev/null 2>&1; then
        echo "✅ PulseAudio daemon running"
        PID=$(ps aux | grep -v grep | grep pulseaudio | awk '{print $2}' | head -1)
        echo "   PID: $PID"
      else
        echo "❌ PulseAudio not running"
        echo "   Run: audio-start"
        exit 1
      fi

      # Check if Simple Protocol module is loaded
      if ${pkgs.pulseaudio}/bin/pactl list modules short | grep -q simple-protocol-tcp; then
        echo "✅ Audio streaming module loaded"
        MODULE_ID=$(${pkgs.pulseaudio}/bin/pactl list modules short | grep simple-protocol-tcp | awk '{print $1}')
        echo "   Module ID: $MODULE_ID"
      else
        echo "❌ Audio module not loaded"
        echo "   Run: audio-start"
      fi

      # Check if port is listening
      if ${pkgs.netcat}/bin/nc -z localhost 12345 2>/dev/null; then
        echo "✅ Port 12345 is open"
      else
        echo "❌ Port 12345 not listening"
      fi

      # Check mopidy status
      if ps aux | grep -v grep | grep -q mopidy; then
        echo "✅ Mopidy is running"
      else
        echo "⚠️  Mopidy not running"
        echo "   Run: mopidy-bg"
      fi

      # Show connection info
      echo ""
      echo "Connection details:"
      IP=$(get-ip)
      echo "  Server: $IP:12345"
      echo "  Protocol: Simple Protocol (TCP)"
      echo "  Quality: 16-bit/44.1kHz Stereo"
    '')

    # Stop audio streaming
    (writeScriptBin "audio-stop" ''
      #!${bash}/bin/bash
      echo "Stopping audio streaming..."

      # Stop PulseAudio
      ${pkgs.pulseaudio}/bin/pulseaudio --kill 2>/dev/null && \
        echo "✅ PulseAudio stopped" || \
        echo "⚠️  PulseAudio was not running"

      # Stop mopidy if running
      if ps aux | grep -v grep | grep -q mopidy; then
        mopidy-stop
      fi
    '')

    # Audio troubleshooting helper
    (writeScriptBin "audio-debug" ''
      #!${bash}/bin/bash
      echo "═══════════════════════════════════════════════════════"
      echo "          Audio Streaming Troubleshooting"
      echo "═══════════════════════════════════════════════════════"
      echo ""

      # System info
      echo "📱 System Information:"
      echo "  • Device: $(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
      echo "  • Android: $(getprop ro.build.version.release 2>/dev/null || echo 'Unknown')"
      echo "  • Kernel: $(uname -r)"
      echo ""

      # Network info
      echo "🌐 Network Status:"
      IP=$(get-ip)
      echo "  • IP Address: $IP"
      echo "  • WiFi: $(getprop wlan.driver.status 2>/dev/null || echo 'Check Settings')"
      echo ""

      # PulseAudio detailed check
      echo "🔊 PulseAudio Status:"
      if ${pkgs.pulseaudio}/bin/pactl info >/dev/null 2>&1; then
        echo "  ✅ Daemon running"
        echo ""
        echo "  Server Info:"
        ${pkgs.pulseaudio}/bin/pactl info 2>/dev/null | sed 's/^/    /'
        echo ""
        echo "  Loaded Modules:"
        ${pkgs.pulseaudio}/bin/pactl list modules short | grep -E "(simple-protocol|native-protocol)" | sed 's/^/    /'
      else
        echo "  ❌ Not running"
        echo "  Try: pulseaudio -vvv (for debug output)"
      fi
      echo ""

      # Port check
      echo "🔌 Port Status:"
      for port in 12345 6600 6680 4713; do
        if ${pkgs.netcat}/bin/nc -z localhost $port 2>/dev/null; then
          echo "  ✅ Port $port: Open"
        else
          echo "  ❌ Port $port: Closed"
        fi
      done
      echo ""

      # Process check
      echo "⚙️ Running Processes:"
      echo "  • Mopidy: $(ps aux | grep -v grep | grep -q mopidy && echo '✅ Running' || echo '❌ Not running')"
      echo "  • PulseAudio: $(${pkgs.pulseaudio}/bin/pactl info >/dev/null 2>&1 && echo '✅ Running' || echo '❌ Not running')"
      echo ""

      # Quick fixes
      echo "🔧 Quick Fixes:"
      echo "  1. Restart everything: audio-stop && audio-start && mopidy-restart"
      echo "  2. Check logs: mopidy-logs"
      echo "  3. Test audio: pactl play-sample bell"
      echo "  4. Debug mode: pulseaudio -vvv"
      echo "═══════════════════════════════════════════════════════"
    '')

    # All-in-one Tidal audio player (runs everything in background)
    (writeScriptBin "tidal" ''
      #!${bash}/bin/bash
      echo "═══════════════════════════════════════════════════════"
      echo "             🎵 Tidal Music Player 🎵"
      echo "═══════════════════════════════════════════════════════"

      # Stop any existing instances
      echo "[*] Cleaning up old processes..."
      for pid in $(ps aux | grep mopidy | grep -v grep | awk '{print $2}'); do
        kill $pid 2>/dev/null
      done
      pkill -f mpv-audio 2>/dev/null
      sleep 1

      # Start mopidy in background
      echo "[1/3] Starting Mopidy server..."
      nohup mopidy-with-extensions --config ~/.config/mopidy/mopidy.conf \
        > ~/.local/share/mopidy/logs/mopidy.log 2>&1 &
      MOPIDY_PID=$!
      echo "    ✅ Mopidy started (PID: $MOPIDY_PID)"

      # Wait for mopidy to be ready
      echo "[2/3] Waiting for Mopidy to initialize..."
      sleep 5
      while ! nc -z localhost 6600 2>/dev/null; do
        echo -n "."
        sleep 1
      done
      echo ""
      echo "    ✅ Mopidy is ready"

      # Start MPV in background
      echo "[3/3] Starting audio output (MPV)..."
      nohup ${pkgs.mpv}/bin/mpv --no-video --audio-display=no \
        --no-terminal-title --really-quiet \
        --cache=yes --cache-secs=10 \
        --volume=100 \
        http://localhost:6680/mopidy/stream \
        > ~/.local/share/mopidy/logs/mpv.log 2>&1 &
      MPV_PID=$!
      echo "    ✅ Audio output ready (PID: $MPV_PID)"

      echo ""
      echo "───────────────────────────────────────────────────────"
      echo "✅ Everything is running! Now open ncmpcpp:"
      echo "───────────────────────────────────────────────────────"
      echo ""

      # Launch ncmpcpp
      echo "Launching music player interface..."
      echo ""
      echo "Controls:"
      echo "  4 - Search for music"
      echo "  Enter - Add to playlist"
      echo "  p - Play/Pause"
      echo "  ] - Next track"
      echo "  [ - Previous track"
      echo "  q - Quit player (music keeps playing)"
      echo ""
      echo "To stop everything later: tidal-stop"
      echo "═══════════════════════════════════════════════════════"
      echo ""

      # Run ncmpcpp in foreground
      ncmpcpp
    '')

    # Stop all Tidal processes
    (writeScriptBin "tidal-stop" ''
      #!${bash}/bin/bash
      echo "Stopping Tidal music player..."

      # Kill MPV
      pkill -f "mpv.*mopidy/stream" 2>/dev/null && echo "✅ Stopped audio output"

      # Kill Mopidy
      for pid in $(ps aux | grep mopidy | grep -v grep | awk '{print $2}'); do
        kill $pid 2>/dev/null
      done
      echo "✅ Stopped Mopidy server"

      echo "All services stopped."
    '')

    # Start MPV audio player for Mopidy stream
    (writeScriptBin "mpv-audio" ''
      #!${bash}/bin/bash
      echo "Starting MPV audio player for Mopidy stream..."
      echo ""

      # Check if mopidy is running
      if ! ps aux | grep -v grep | grep -q mopidy; then
        echo "⚠️  Mopidy is not running!"
        echo "Start it with: mopidy-bg"
        exit 1
      fi

      echo "📱 MPV Audio Player"
      echo "═══════════════════════"
      echo "Connecting to Mopidy HTTP stream..."
      echo "This will play audio directly through your phone speakers!"
      echo ""
      echo "Controls:"
      echo "  Space - Pause/Resume"
      echo "  q - Quit"
      echo "  9/0 - Volume down/up"
      echo "  < > - Seek backward/forward"
      echo ""
      echo "Use ncmpcpp in another terminal to control playback"
      echo "───────────────────────────────────────────────────"

      # Start MPV with audio-only mode, connecting to Mopidy's HTTP stream
      ${pkgs.mpv}/bin/mpv --no-video --audio-display=no --no-terminal-title \
        --cache=yes --cache-secs=10 \
        --volume=100 \
        http://localhost:6680/mopidy/stream
    '')

    # Quick start guide for Tidal streaming
    (writeScriptBin "tidal-quickstart" ''
      #!${bash}/bin/bash
      echo "═══════════════════════════════════════════════════════"
      echo "          Tidal Music Streaming Quick Start"
      echo "═══════════════════════════════════════════════════════"
      echo ""
      echo "📝 Prerequisites:"
      echo "  • Tidal account (subscription required)"
      echo "  • Simple Protocol Player app"
      echo "  • WiFi connection"
      echo ""
      echo "🚀 Setup Steps:"
      echo ""
      echo "1️⃣  Start audio streaming:"
      echo "    $ audio-start"
      echo ""
      echo "2️⃣  Install Simple Protocol Player:"
      echo "    Download from: https://github.com/kaytat/SimpleProtocolPlayer/releases"
      echo "    Choose: SimpleProtocolPlayer-<version>-arm64-v8a.apk"
      echo ""
      echo "3️⃣  Configure the app:"
      IP=$(get-ip 2>/dev/null || echo "<your-ip>")
      echo "    • Server: $IP"
      echo "    • Port: 12345"
      echo "    • Sample Rate: 44100 Hz"
      echo "    • Format: 16-bit PCM"
      echo "    • Channels: Stereo"
      echo ""
      echo "4️⃣  Start Mopidy:"
      echo "    $ mopidy-bg"
      echo ""
      echo "5️⃣  Open music player:"
      echo "    $ ncmpcpp  (or $ music)"
      echo ""
      echo "🎵 Using ncmpcpp:"
      echo "  • Press 2: Browse library"
      echo "  • Press 4: Search for songs"
      echo "  • Press Enter: Add to playlist"
      echo "  • Press p: Play/pause"
      echo "  • Press s: Stop"
      echo "  • Press ]: Next track"
      echo "  • Press [: Previous track"
      echo "  • Press q: Quit"
      echo ""
      echo "🔍 Troubleshooting:"
      echo "  • Check status: audio-check"
      echo "  • View logs: mopidy-logs"
      echo "  • Debug mode: audio-debug"
      echo "  • Restart all: audio-stop && audio-start && mopidy-restart"
      echo ""
      echo "📱 Remember:"
      echo "  • Keep phone and terminal on same WiFi"
      echo "  • Simple Protocol Player must be running"
      echo "  • Audio quality: CD (16-bit/44.1kHz)"
      echo "═══════════════════════════════════════════════════════"
    '')

    # Debug helper to check extension loading
    (writeScriptBin "mopidy-debug" ''
      #!${bash}/bin/bash
      echo "=== Mopidy Extension Debug ==="
      echo ""

      echo "1. Checking package locations:"
      echo "   mopidy: ${pkgs.mopidy}"
      echo "   mopidy-mpd: ${pkgs.mopidy-mpd}"
      echo "   mopidy-tidal: ${pkgs.mopidy-tidal}"
      echo ""

      echo "2. Checking Python paths in packages:"
      for pkg in ${pkgs.mopidy-tidal} ${pkgs.mopidy-mpd}; do
        echo "   Package: $pkg"
        ls -la $pkg/lib/python*/site-packages 2>/dev/null || echo "     No site-packages found"
      done
      echo ""

      echo "3. Running path debug:"
      mopidy-with-extensions --debug-paths
      echo ""

      echo "4. Checking mopidy extension discovery:"
      mopidy-with-extensions deps 2>&1 | head -20
    '')

    # Mopidy config setup helper
    (writeScriptBin "mopidy-setup" ''
      #!${bash}/bin/bash
      mkdir -p ~/.config/mopidy
      mkdir -p ~/.local/share/mopidy

      if [ -f ~/.config/mopidy/mopidy.conf ]; then
        echo "Mopidy configuration already exists at ~/.config/mopidy/mopidy.conf"
        echo "Edit it with: nvim ~/.config/mopidy/mopidy.conf"
      else
        echo "Creating Mopidy configuration..."
        cat > ~/.config/mopidy/mopidy.conf <<'EOF'
[core]
restore_state = true
cache_dir = ~/.cache/mopidy
data_dir = ~/.local/share/mopidy

[mpd]
enabled = true
hostname = 127.0.0.1
port = 6600
password =
max_connections = 20
connection_timeout = 60

[tidal]
enabled = true
quality = LOSSLESS
# OAuth tokens are stored automatically after authentication

[audio]
mixer = software
mixer_volume =
output = pulsesink

[file]
enabled = false
EOF
        echo ""
        echo "✓ Configuration created at ~/.config/mopidy/mopidy.conf"
        echo ""
        echo "NEXT STEPS:"
        echo "1. Authenticate with Tidal using OAuth:"
        echo "   mopidy-tidal-auth"
        echo ""
        echo "2. Start mopidy:"
        echo "   mopidy-start"
        echo ""
        echo "3. Connect with ncmpcpp:"
        echo "   ncmpcpp"
      fi
    '')

    # Mopidy Tidal OAuth authentication helper
    (writeScriptBin "mopidy-tidal-auth" ''
      #!${bash}/bin/bash
      echo "═══════════════════════════════════════════════════════"
      echo "         Mopidy-Tidal OAuth Authentication"
      echo "═══════════════════════════════════════════════════════"
      echo ""

      # Create config directory if needed
      mkdir -p ~/.config/mopidy
      mkdir -p ~/.local/share/mopidy

      # Check if mopidy-tidal is available
      if ! ${pkgs.python3}/bin/python -c "
import sys
sys.path.extend([
    '${pkgs.mopidy}/lib/python3.11/site-packages',
    '${pkgs.mopidy-tidal}/lib/python3.11/site-packages',
    '${pkgs.python3Packages.pykka}/lib/python3.11/site-packages',
    '${pkgs.python3Packages.setuptools}/lib/python3.11/site-packages'
])
try:
    import mopidy_tidal
    print('✓ mopidy-tidal found')
except:
    print('✗ mopidy-tidal not found')
    sys.exit(1)
" 2>/dev/null; then
        echo "Error: mopidy-tidal is not properly installed"
        exit 1
      fi

      echo "Starting OAuth authentication flow..."
      echo ""

      # Run the OAuth authentication
      ${pkgs.python3}/bin/python << 'PYTHON_EOF'
import sys
import os
import json
from pathlib import Path

# Add all required dependencies to path
sys.path.insert(0, '${pkgs.python3Packages.setuptools}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.pykka}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.mopidy}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.mopidy-tidal}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.tidalapi}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.requests}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.urllib3}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.certifi}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.charset-normalizer}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.idna}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.python-dateutil}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.six}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.isodate}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.mpegdash}/lib/python3.11/site-packages')
sys.path.insert(0, '${pkgs.python3Packages.typing-extensions}/lib/python3.11/site-packages')

try:
    import tidalapi

    # OAuth flow
    session = tidalapi.Session()

    # Start login process
    login, future = session.login_oauth()

    print("Please visit this URL to authenticate:")
    print(f"\n{login.verification_uri_complete}\n")
    print("Waiting for authentication...")

    # Wait for authentication
    future.result()

    if session.check_login():
        # Save tokens to the location mopidy-tidal expects
        token_dir = Path.home() / '.local' / 'share' / 'mopidy' / 'tidal'
        token_dir.mkdir(parents=True, exist_ok=True)
        token_file = token_dir / 'tidal-oauth.json'

        token_data = {
            'token_type': session.token_type or 'Bearer',
            'access_token': session.access_token,
            'refresh_token': session.refresh_token,
            'expiry_time': session.expiry_time.isoformat() if session.expiry_time else None
        }

        with open(token_file, 'w') as f:
            json.dump(token_data, f, indent=2)

        print("\n✓ Authentication successful!")
        print(f"✓ Tokens saved to {token_file}")
        print("\nYou can now start mopidy with: mopidy-start")
    else:
        print("\n✗ Authentication failed")
        sys.exit(1)

except ImportError as e:
    print(f"Error importing tidalapi: {e}")
    print("\nMake sure tidalapi is properly installed")
    sys.exit(1)
except Exception as e:
    print(f"Error during authentication: {e}")
    sys.exit(1)
PYTHON_EOF

      if [ $? -eq 0 ]; then
        echo ""
        echo "═══════════════════════════════════════════════════════"
        echo "✓ Setup complete! You can now use:"
        echo "  1. mopidy-bg     - Start Mopidy in background"
        echo "  2. ncmpcpp       - Control playback"
        echo "═══════════════════════════════════════════════════════"
      fi
    '')

    # Mopidy check/debug script
    (writeScriptBin "mopidy-check" ''
      #!${bash}/bin/bash
      echo "Checking Mopidy installation..."
      echo ""

      echo "✓ Mopidy version:"
      ${pkgs.mopidy}/bin/mopidy --version
      echo ""

      echo "✓ Available extensions:"
      ${pkgs.mopidy}/bin/mopidy deps | grep -E "Mopidy-|Found"
      echo ""

      echo "✓ Checking for mopidy-tidal:"
      if ${pkgs.python3}/bin/python -c "import sys; sys.path.extend(['${pkgs.mopidy-tidal}/${pkgs.python3.sitePackages}']); import mopidy_tidal" 2>/dev/null; then
        echo "  mopidy-tidal is installed correctly"
      else
        echo "  WARNING: mopidy-tidal not found"
      fi
      echo ""

      echo "✓ Configuration status:"
      if [ -f ~/.config/mopidy/mopidy.conf ]; then
        echo "  Config exists at ~/.config/mopidy/mopidy.conf"
        if grep -q "YOUR_EMAIL" ~/.config/mopidy/mopidy.conf; then
          echo "  ⚠ WARNING: Tidal credentials not configured yet!"
        else
          echo "  Tidal credentials appear to be configured"
        fi
      else
        echo "  No config found - run 'mopidy-setup' first"
      fi
      echo ""

      echo "✓ MPD port status (6600):"
      if ${pkgs.netcat}/bin/nc -z 127.0.0.1 6600 2>/dev/null; then
        echo "  Port 6600 is in use (mopidy may be running)"
      else
        echo "  Port 6600 is free"
      fi
    '')

    # Claude Code wrapper script (adapted from claude-code.nix)
    (writeScriptBin "claude" ''
      #!${bash}/bin/bash
      CLAUDE_DIR="$HOME/.local/share/claude-code"
      CLAUDE_BIN="$CLAUDE_DIR/node_modules/.bin/claude"

      if [ ! -f "$CLAUDE_BIN" ]; then
        echo "Claude Code not found. Installing..."
        mkdir -p "$CLAUDE_DIR"
        cd "$CLAUDE_DIR"

        cat > package.json <<EOF
      {
        "name": "claude-code-local",
        "version": "1.0.0",
        "dependencies": {
          "@anthropic-ai/claude-code": "latest"
        }
      }
      EOF

        ${nodejs}/bin/npm install --production

        if [ -f "$CLAUDE_BIN" ]; then
          echo "Claude Code installed successfully!"
        else
          echo "Failed to install Claude Code"
          exit 1
        fi
      fi

      export NODE_PATH="$CLAUDE_DIR/node_modules"
      exec ${nodejs}/bin/node "$CLAUDE_BIN" "$@"
    '')

    # Task master installer (from task-master.nix)
    (writeScriptBin "task-master-installer" ''
      #!${bash}/bin/bash
      echo "Installing task-master-ai..."
      ${nodejs}/bin/npm install -g task-master-ai
    '')
  ];

  # MPV configuration (from mpv.nix) - adapted for CLI usage
  programs.mpv = {
    enable = true;

    config = {
      # Terminal output for Android
      vo = "tct";  # Terminal output that works without X/Wayland
      ao = "pulse";  # PulseAudio for Android

      # YouTube playback
      ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
      ytdl-raw-options = "ignore-errors=,sub-lang=en,write-auto-sub=";

      # Performance
      cache = true;
      cache-secs = 300;
      demuxer-max-bytes = "500M";
      demuxer-max-back-bytes = "250M";

      # Terminal UI
      terminal = true;
      msg-level = "all=warn";

      # No hardware acceleration on Android
      hwdec = "no";
    };

    scripts = with pkgs.mpvScripts; [
      mpris  # Media controls
      quality-menu  # YouTube quality selection
    ];
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$all$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncate_to_repo = false;
        truncation_length = 3;
      };
      git_status = {
        disabled = false;
      };
    };
  };

  # Direnv configuration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Nix-index and comma configuration
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # Fastfetch configuration
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "none";
      };
      display = {
        separator = " : ";
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "memory"
        "disk"
        "battery"
        "poweradapter"
      ];
    };
  };

}
