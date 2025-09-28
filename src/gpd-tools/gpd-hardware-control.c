#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

// GPD Pocket 3 Hardware Control Tool
// Custom hardware integration for advanced GPD features

struct gpd_sensors {
    int cpu_temp;
    int fan_speed;
    int ambient_light;
    int battery_temp;
};

// Read CPU temperature
int read_cpu_temp() {
    FILE *fp = fopen("/sys/class/thermal/thermal_zone0/temp", "r");
    if (!fp) return -1;

    int temp;
    fscanf(fp, "%d", &temp);
    fclose(fp);
    return temp / 1000; // Convert from millidegrees
}

// Read fan speed (if available)
int read_fan_speed() {
    FILE *fp = fopen("/sys/class/hwmon/hwmon0/fan1_input", "r");
    if (!fp) return -1;

    int speed;
    fscanf(fp, "%d", &speed);
    fclose(fp);
    return speed;
}

// Read ambient light sensor (mock for now)
int read_ambient_light() {
    // GPD Pocket 3 may have ambient sensor at different path
    FILE *fp = fopen("/sys/bus/iio/devices/iio:device1/in_illuminance_raw", "r");
    if (!fp) return 50; // Default brightness if sensor not found

    int light;
    fscanf(fp, "%d", &light);
    fclose(fp);
    return light;
}

// Adaptive fan control based on temperature
void set_fan_curve(int temp) {
    printf("🌡️  CPU Temperature: %d°C\n", temp);

    if (temp > 85) {
        printf("🔥 High temp - Max fan speed\n");
        system("echo 255 > /sys/class/hwmon/hwmon0/pwm1 2>/dev/null || true");
    } else if (temp > 70) {
        printf("⚡ Medium temp - Balanced fan\n");
        system("echo 180 > /sys/class/hwmon/hwmon0/pwm1 2>/dev/null || true");
    } else if (temp > 50) {
        printf("✅ Normal temp - Quiet fan\n");
        system("echo 120 > /sys/class/hwmon/hwmon0/pwm1 2>/dev/null || true");
    } else {
        printf("❄️  Cool temp - Min fan\n");
        system("echo 80 > /sys/class/hwmon/hwmon0/pwm1 2>/dev/null || true");
    }
}

// Adaptive keyboard backlight based on ambient light
void set_keyboard_backlight(int ambient) {
    printf("💡 Ambient light: %d lux\n", ambient);

    int brightness;
    if (ambient < 10) {
        brightness = 255; // Dark - max backlight
    } else if (ambient < 50) {
        brightness = 180; // Dim - high backlight
    } else if (ambient < 200) {
        brightness = 120; // Normal - medium backlight
    } else {
        brightness = 60;  // Bright - low backlight
    }

    printf("⌨️  Setting keyboard backlight: %d/255\n", brightness);
    char cmd[256];
    snprintf(cmd, sizeof(cmd), "echo %d > /sys/class/leds/platform::kbd_backlight/brightness 2>/dev/null || true", brightness);
    system(cmd);
}

int main(int argc, char *argv[]) {
    printf("🎯 GPD Pocket 3 Hardware Control Tool\n");
    printf("=====================================\n\n");

    if (argc > 1 && strcmp(argv[1], "--monitor") == 0) {
        printf("Starting continuous monitoring mode...\n\n");

        while (1) {
            struct gpd_sensors sensors = {
                .cpu_temp = read_cpu_temp(),
                .fan_speed = read_fan_speed(),
                .ambient_light = read_ambient_light(),
                .battery_temp = 0 // TODO: implement battery temp reading
            };

            printf("📊 GPD Hardware Status:\n");
            printf("   CPU Temp: %d°C\n", sensors.cpu_temp);
            printf("   Fan Speed: %d RPM\n", sensors.fan_speed);
            printf("   Ambient Light: %d lux\n", sensors.ambient_light);

            // Apply adaptive controls
            set_fan_curve(sensors.cpu_temp);
            set_keyboard_backlight(sensors.ambient_light);

            printf("\n");
            sleep(5); // Update every 5 seconds
        }
    } else {
        // Single reading mode
        struct gpd_sensors sensors = {
            .cpu_temp = read_cpu_temp(),
            .fan_speed = read_fan_speed(),
            .ambient_light = read_ambient_light()
        };

        printf("📊 Current GPD Hardware Status:\n");
        printf("   CPU Temperature: %d°C\n", sensors.cpu_temp);
        printf("   Fan Speed: %d RPM\n", sensors.fan_speed);
        printf("   Ambient Light: %d lux\n", sensors.ambient_light);

        printf("\nUsage: %s [--monitor]\n", argv[0]);
        printf("       --monitor    Continuous monitoring with adaptive control\n");
    }

    return 0;
}