/*
 * ACPI DSDT Override for GPD Pocket 3
 * Fixes missing ACPI symbols that cause AE_NOT_FOUND errors
 */

DefinitionBlock ("acpi-override.aml", "SSDT", 2, "GPD", "FIXACPI", 0x00000001)
{
    External (_SB.PC00.I2C0, DeviceObj)
    External (_SB.PC00.I2C2, DeviceObj)
    External (_SB.PC00.LPCB.H_EC, DeviceObj)
    External (_SB.UBTC, DeviceObj)
    External (_SB.PC00.TXHC.RHUB, DeviceObj)
    External (_SB.PC00.XHCI.RHUB, DeviceObj)

    /*
     * Fix missing touchpad/touchscreen I2C device stubs
     * Error: Could not resolve symbol [\_SB.PC00.I2C0.TPD0]
     */
    Scope (\_SB.PC00.I2C0)
    {
        Device (TPD0)
        {
            Name (_HID, "MSFT0001")  // Generic touchpad HID
            Name (_CID, "PNP0C50")   // Precision touchpad compatible
            Name (_UID, Zero)

            Method (_STA, 0, NotSerialized)
            {
                Return (0x00)  // Device not present (stub only)
            }
        }

        Device (TPL1)
        {
            Name (_HID, "MSFT0001")
            Name (_CID, "PNP0C50")
            Name (_UID, One)

            Method (_STA, 0, NotSerialized)
            {
                Return (0x00)  // Device not present (stub only)
            }
        }
    }

    Scope (\_SB.PC00.I2C2)
    {
        Device (TPL1)
        {
            Name (_HID, "MSFT0001")
            Name (_CID, "PNP0C50")
            Name (_UID, 0x02)

            Method (_STA, 0, NotSerialized)
            {
                Return (0x00)  // Device not present (stub only)
            }
        }
    }

    /*
     * Fix missing USB Type-C UCSI RUCC method
     * Error: Could not resolve symbol [\_SB.UBTC.RUCC]
     */
    Scope (\_SB)
    {
        Device (UBTC)
        {
            Name (_HID, "USBC000")
            Name (_CID, "PNP0CA0")  // UCSI device
            Name (_UID, Zero)

            Method (_STA, 0, NotSerialized)
            {
                Return (0x00)  // Device not present (stub only)
            }

            Method (RUCC, 0, NotSerialized)
            {
                // Stub method - returns empty package
                Return (Package (0x00) {})
            }
        }
    }

    /*
     * Fix missing embedded controller sensor SEN4
     * Error: Could not resolve symbol [\_SB.PC00.LPCB.HEC.SEN4]
     */
    Scope (\_SB.PC00.LPCB.H_EC)
    {
        // Create alias for HEC if it exists
        External (\_SB.PC00.LPCB.HEC, DeviceObj)

        Name (SEN4, Package (0x05)
        {
            0x00,  // Sensor type
            0x00,  // Sensor status
            0x00,  // Current value
            0x00,  // Min value
            0x00   // Max value
        })
    }

    // Also create the same in HEC scope if it's different from H_EC
    Scope (\_SB.PC00.LPCB)
    {
        Device (HEC)
        {
            Name (_HID, "EC000000")

            Method (_STA, 0, NotSerialized)
            {
                Return (0x00)  // Stub only
            }

            Name (SEN4, Package (0x05)
            {
                0x00, 0x00, 0x00, 0x00, 0x00
            })
        }
    }
}
