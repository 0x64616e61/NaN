{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.applications.btop;
in
{
  options.custom.hm.applications.btop = {
    enable = mkEnableOption "btop++ system monitor configuration";
  };

  config = mkIf cfg.enable {
    # Configure btop++ with your preferred settings
    programs.btop = {
      enable = true;
      
      settings = {
        # Theme and appearance
        color_theme = "Default";
        theme_background = true;
        truecolor = true;
        force_tty = false;
        rounded_corners = true;
        
        # Graph settings
        graph_symbol = "braille";
        graph_symbol_cpu = "default";
        graph_symbol_gpu = "default";
        graph_symbol_mem = "default";
        graph_symbol_net = "default";
        graph_symbol_proc = "default";
        
        # Layout
        shown_boxes = "cpu mem net proc";
        presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
        
        # Update and behavior
        update_ms = 2000;
        vim_keys = false;
        background_update = true;
        
        # Process settings
        proc_sorting = "cpu lazy";
        proc_reversed = false;
        proc_tree = false;
        proc_colors = true;
        proc_gradient = true;
        proc_per_core = false;
        proc_mem_bytes = true;
        proc_cpu_graphs = true;
        proc_info_smaps = false;
        proc_left = false;
        proc_filter_kernel = false;
        proc_aggregate = false;
        
        # CPU settings
        cpu_graph_upper = "Auto";
        cpu_graph_lower = "Auto";
        show_gpu_info = "Auto";
        cpu_invert_lower = true;
        cpu_single_graph = false;
        cpu_bottom = false;
        show_uptime = true;
        check_temp = true;
        cpu_sensor = "Auto";
        show_coretemp = true;
        cpu_core_map = "";
        temp_scale = "celsius";
        show_cpu_freq = true;
        custom_cpu_name = "";
        
        # Clock and display
        clock_format = "%X";
        base_10_sizes = false;
        
        # Memory settings
        mem_graphs = true;
        mem_below_net = false;
        zfs_arc_cached = true;
        show_swap = true;
        swap_disk = true;
        show_disks = true;
        only_physical = true;
        use_fstab = true;
        zfs_hide_datasets = false;
        disk_free_priv = false;
        show_io_stat = true;
        io_mode = false;
        io_graph_combined = false;
        io_graph_speeds = "";
        disks_filter = "";
        
        # Network settings
        net_download = 100;
        net_upload = 100;
        net_auto = true;
        net_sync = true;
        net_iface = "";
        base_10_bitrate = "Auto";
        
        # Battery settings (important for GPD Pocket 3)
        show_battery = true;
        selected_battery = "Auto";
        show_battery_watts = true;
        
        # GPU settings
        nvml_measure_pcie_speeds = true;
        rsmi_measure_pcie_speeds = true;
        gpu_mirror_graph = true;
        custom_gpu_name0 = "";
        custom_gpu_name1 = "";
        custom_gpu_name2 = "";
        custom_gpu_name3 = "";
        custom_gpu_name4 = "";
        custom_gpu_name5 = "";
        
        # Logging
        log_level = "WARNING";
      };
    };
    
    # Ensure btop themes directory exists
    home.file.".config/btop/themes/.keep".text = "";
  };
}