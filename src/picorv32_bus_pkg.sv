/*
 * ============================================================================
 * Package     : picorv32_bus_pkg
 * Description : System-wide Bus Interface Definitions.
 * This package defines the Request/Response structures for the PicoRV32 
 * processor and its peripheral ecosystem. Using packed structures ensures 
 * hardware-level bit-mapping while improving code readability and routing.
 *
 * ============================================================================
 * Data Structures:
 * ----------------------------------------------------------------------------
 * rv32_req_t (Master -> Slave):
 * - select    : Bus request valid signal (Activates the addressed peripheral).
 * - wstrb [3:0]: Write Strobe (Indicates which bytes of 'wdata' are valid).
 * 4'b0000 = Read operation.
 * 4'b1111 = 32-bit Word Write.
 * - addr [31:0]: Target memory or peripheral register address.
 * - wdata[31:0]: Data to be written to the slave.
 *
 * rv32_resp_t (Slave -> Master):
 * - rdata[31:0]: Data read from the slave (Valid only when 'ready' is High).
 * - ready     : Acknowledgment signal (Indicates completion of the transaction).
 * ----------------------------------------------------------------------------
 *
 * Usage Note: 
 * Always 'import picorv32_bus_pkg::*' at the top of your modules to 
 * access these types.
 *
 * ============================================================================
 */
package picorv32_bus_pkg;

    // Signaux pilotés par le CPU (Master -> Slave)
    typedef struct packed {
        logic        select;
        logic [3:0]  wstrb;
        logic [31:0] addr;
        logic [31:0] wdata;
    } rv32_req_t;

    // Signaux pilotés par la Mémoire/Périphérique (Slave -> Master)
    typedef struct packed {
        logic [31:0] rdata;
        logic        ready;
    } rv32_resp_t;

endpackage
