# GPD Pocket 3 Hardware Todos

Documentation of identified hardware gaps and implementation roadmap for enhanced hardware support.

## Critical Missing Components

### 1. Thermal Management (CRITICAL)
**Status**: Missing - No thermal control implementation
**Priority**: 🔴 Critical
**Impact**: Risk of overheating, throttling, reduced performance

**Current Gap**:
- No CPU thermal monitoring
- No fan curve management
- No temperature-based throttling
- No thermal emergency actions

**Implementation Required**:
```nix
# modules/system/hardware/thermal-management.nix
custom.system.hardware.thermal = {
  enable = true;
  cpu.maxTemp = 85;  # Celsius
  fanCurve = {
    silent = true;
    curves = [
      { temp = 40; speed = 20; }
      { temp = 60; speed = 50; }
      { temp = 80; speed = 100; }
    ];
  };
  emergency = {
    shutdownTemp = 95;
    throttleTemp = 85;
  };
};
```

**Dependencies**:
- `thermald` service
- `lm-sensors` for temperature monitoring
- Intel P-state driver configuration
- Fan control via ACPI or EC interface

### 2. Battery Optimization
**Status**: Basic power management only
**Priority**: 🟡 Important
**Impact**: Reduced battery life, suboptimal power efficiency

**Current State**:
- Basic lid behavior control ✅
- Suspend control available ✅
- No battery health monitoring ❌
- No power profile switching ❌
- No charging thresholds ❌

**Missing Features**:
- Battery charge threshold management
- Power profile switching (performance/balanced/power-save)
- Battery health monitoring
- Intel TLP integration
- Wake source control

**Implementation Required**:
```nix
# modules/system/hardware/battery-optimization.nix
custom.system.hardware.battery = {
  enable = true;
  chargeThreshold = {
    start = 20;
    stop = 80;
  };
  powerProfiles = {
    enable = true;
    default = "balanced";
  };
  tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };
};
```

### 3. Hardware Monitoring
**Status**: Limited accelerometer monitoring only
**Priority**: 🟡 Important
**Impact**: No system health visibility, reactive maintenance only

**Current Monitoring**:
- Accelerometer for auto-rotation ✅
- Basic IIO sensor proxy ✅
- No temperature monitoring ❌
- No fan speed monitoring ❌
- No voltage/power monitoring ❌

**Missing Monitoring**:
- CPU/GPU temperatures
- Fan speeds and control
- Battery health metrics
- Memory temperature
- Storage health (SMART)
- Power consumption tracking

**Implementation Required**:
```nix
# modules/system/hardware/monitoring.nix
custom.system.hardware.monitoring = {
  enable = true;
  sensors = {
    temperature = true;
    fan = true;
    voltage = true;
    power = true;
  };
  alerts = {
    highTemp = 80;
    lowBattery = 15;
    fanFailure = true;
  };
  logging = {
    enable = true;
    interval = "30s";
    retention = "30d";
  };
};
```

### 4. Touch Input Enhancements
**Status**: Basic rotation support
**Priority**: 🟢 Nice to have
**Impact**: Suboptimal touch experience

**Current Implementation**:
- Touch rotation with display ✅
- Basic device recognition ✅
- No calibration support ❌
- No gesture customization ❌
- No palm rejection ❌

**Enhancement Opportunities**:
- Touch calibration tools
- Advanced gesture recognition
- Palm rejection algorithms
- Pressure sensitivity tuning
- Multi-touch optimization

**Implementation Path**:
```nix
# modules/system/hardware/touch-enhancements.nix
custom.system.hardware.touch = {
  enable = true;
  calibration = {
    enable = true;
    autoCalibrate = true;
  };
  gestures = {
    palmRejection = true;
    pressureSensitivity = "medium";
    customGestures = [ ];
  };
};
```

### 5. Intel Graphics Optimization
**Status**: Basic driver support
**Priority**: 🟢 Nice to have
**Impact**: Suboptimal graphics performance and power efficiency

**Current State**:
- Basic Intel graphics driver ✅
- No specific optimizations ❌
- No power management tuning ❌
- No performance profiles ❌

**Optimization Areas**:
- Intel GPU frequency scaling
- Video decode acceleration
- Power state management
- Memory bandwidth optimization
- Display pipeline tuning

**Implementation Strategy**:
```nix
# modules/system/hardware/intel-graphics.nix
custom.system.hardware.intelGraphics = {
  enable = true;
  powerManagement = {
    enable = true;
    rc6 = "enabled";
    fbc = true;
  };
  performance = {
    profile = "balanced";
    boostFreq = "auto";
  };
  video = {
    hwAccel = true;
    vaapi = true;
  };
};
```

## Implementation Priority Matrix

| Component | Priority | Effort | Impact | Dependencies |
|-----------|----------|---------|---------|--------------|
| Thermal Management | 🔴 Critical | High | High | thermald, lm-sensors |
| Battery Optimization | 🟡 Important | Medium | High | TLP, power-profiles |
| Hardware Monitoring | 🟡 Important | Medium | Medium | lm-sensors, smartctl |
| Touch Enhancements | 🟢 Nice to have | Low | Low | libinput |
| Intel Graphics | 🟢 Nice to have | Medium | Medium | mesa, vaapi |

## Next Steps

### Phase 1: Critical Infrastructure (Week 1-2)
1. Implement thermal management module
2. Add temperature monitoring and alerts
3. Configure emergency thermal actions
4. Test thermal throttling behavior

### Phase 2: Power Optimization (Week 3-4)
1. Implement battery optimization module
2. Add TLP integration with GPD Pocket 3 presets
3. Configure power profiles
4. Add battery health monitoring

### Phase 3: Enhanced Monitoring (Week 5-6)
1. Expand hardware monitoring capabilities
2. Add alerting and logging systems
3. Create health dashboards
4. Implement proactive maintenance alerts

### Phase 4: Experience Enhancements (Week 7-8)
1. Touch input calibration and optimization
2. Intel graphics performance tuning
3. Advanced gesture support
4. Final integration testing

## Hardware Detection Commands

For implementation reference:
```bash
# Thermal sensors
sensors
find /sys/class/thermal -name "temp*"

# Battery information
upower -i $(upower -e | grep 'BAT')
cat /sys/class/power_supply/BAT*/uevent

# Intel graphics
lspci | grep VGA
cat /sys/kernel/debug/dri/0/i915_frequency_info

# Touch devices
libinput list-devices
xinput list

# Hardware monitoring
lm-sensors
smartctl -a /dev/nvme0n1
```

## Risk Assessment

**High Risk**:
- No thermal protection could damage hardware
- Poor battery management reduces device lifespan

**Medium Risk**:
- Limited monitoring means reactive maintenance only
- Suboptimal performance without proper tuning

**Low Risk**:
- Touch and graphics optimizations are convenience features
- Current functionality is stable baseline