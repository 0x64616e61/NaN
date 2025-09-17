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

  # Zsh configuration with your aliases
  programs.zsh = {
    enable = true;

    initExtra = ''
      # Set default editor
      export EDITOR=nvim
      export VISUAL=nvim

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

    # For better compatibility
    TERM = "xterm-256color";
    COLORTERM = "truecolor";

    # Locale settings
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # Additional packages for home environment
  home.packages = with pkgs; [
    # Python packages for development
    python3
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.wheel
    python3Packages.requests
    python3Packages.click
    python3Packages.pyyaml
    python3Packages.rich

    # Additional CLI tools
    signal-cli  # From your desktop config

    # Task management tools (from task-master.nix)
    nodejs  # Required for task-master and claude-code

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

  # Add claude code alias to shell aliases
  programs.zsh.shellAliases = programs.zsh.shellAliases // {
    cc = "claude";  # Alias for claude-code
  };
}
