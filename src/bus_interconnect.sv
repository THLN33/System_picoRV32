/*
 * ============================================================================
 * Module      : bus_interconnect
 * Description : Central System Bus Interconnect / Crossbar.
 * Performs address decoding and request routing from the PicoRV32 Master 
 * to various Slave peripherals (SRAM, UART, Timers, Video, etc.).
 *
 * Architecture:
 * - Protocol: Native PicoRV32 Bus (rv32_req_t / rv32_resp_t).
 * - Decoding: Combinational address decoding (logic-based Chip Select).
 * - Routing:  Direct request distribution and multiplexed response collection.
 * ============================================================================
 * Address Map:
 * ----------------------------------------------------------------------------
 * Range                  | Peripheral      | Size       | Description
 * ----------------------------------------------------------------------------
 * 0x00000000-0x00001FFF  | Internal SRAM   | 8 KB       | Boot/Program RAM.
 * 0x20000000-0x2000FFFF  | Expansion SRAM  | 64 KB MAX  | Extended Data RAM.
 * 0x30000000-0x30007FFF  | Video RAM       | 32 KB MAX  | Character Engine.
 * 0x80000000-0x80000003  | Port I/O        | 4 Bytes    | GPIO Control.
 * 0x80000008-0x8000000F  | UART            | 8 Bytes    | Serial Comm.
 * 0x80000010-0x8000001F  | Timer           | 16 Bytes   | Adv. Timer.
 * 0xE0000000-0xE000000F  | System Config   | 16 Bytes   | HW ID & Clocks.
 * ----------------------------------------------------------------------------
 *
 * Implementation Details:
 * - Fault Tolerance: Unmapped addresses return 0xDEADBEEF and assert 
 * 'ready' immediately to prevent the CPU from hanging (bus lockup).
 * - Scalability: Uses parameters for easy adjustments to memory boundaries.
 * - Latency: Purely combinational; does not add clock cycles to the bus path.
 *
 * ============================================================================
 */
import picorv32_bus_pkg::*;


module bus_interconnect (
        //input       clk,

        // CPU =>
        input  rv32_req_t  cpu_req,   // Requête venant du CPU
        output rv32_resp_t cpu_resp,  // Réponse renvoyée au CPU

        // => SRAM
        output rv32_req_t  sram_req,
        input  rv32_resp_t sram_resp,

        // => SRAM_EXT
        output rv32_req_t  sram_ext_req,
        input  rv32_resp_t sram_ext_resp,

        // => system_config
        output rv32_req_t  system_config_req,
        input  rv32_resp_t system_config_resp,

        // => cdt
        output rv32_req_t  timer_req,
        input  rv32_resp_t timer_resp,

        // => uart
        output rv32_req_t  uart_req,
        input  rv32_resp_t uart_resp,

        // => Port
        output rv32_req_t  port_req,
        input  rv32_resp_t port_resp,

        // => SRAM_VIDEO
        output rv32_req_t  ram_video_req,
        input  rv32_resp_t ram_video_resp
    );

    parameter SRAM_BOOT_ADDR       = 32'h0000_0000;
    parameter SRAM_BOOT_SIZE       = 32'h0000_2000;

    parameter SRAM_EXT_ADDR         = 32'h2000_0000;
    parameter SRAM_EXT_SIZE         = 32'h0001_0000;            

    parameter SYSTEM_CONFIG_ADDR    = 32'hE000_0000;
    parameter SYSTEM_CONFIG_SIZE    = 32'd16;       // 4 words, 16 bytes

    parameter TIMER_ADDR            = 32'h8000_0010;
    parameter TIMER_SIZE            = 32'd16;       // 4 words, 16 bytes

    parameter UART_ADDR             = 32'h8000_0008;
    parameter UART_SIZE             = 32'd8;        // 2 words, 8 bytes

    parameter PORT_ADDR             = 32'h8000_0000;
    parameter PORT_SIZE             = 32'd4;        // 1 words, 4 bytes

    parameter VIDEO_RAM_BUS_ADDR    = 32'h3000_0000;
    parameter VIDEO_RAM_BUS_SIZE    = 32'h0000_8000;


    // Logique de décodage (Chip Select)
    //   SRAM                   00000000 - 00001fff 
    //   SRAM_64K               20000000 - 2000ffff
    //   SRAM video text        30000000 ...     
    //   Port                   80000000 - 80000003
    //   UART                   80000008 - 8000000f
    //   TIMER                  80000010 - 8000001F
    //   SYSTEM_CONFIG          E0000000 - E000000F  

    assign sram_sel = (cpu_req.addr < (SRAM_BOOT_ADDR + SRAM_BOOT_SIZE));
    //assign sram_ext_sel = (cpu_req.addr >= SRAM_EXT_ADDR) && (cpu_req.addr < (SRAM_EXT_ADDR+SRAM_EXT_SIZE));
    assign sram_ext_sel = (cpu_req.addr & ~(SRAM_EXT_SIZE-1)) == SRAM_EXT_ADDR;
    assign system_config_sel = ((cpu_req.addr & ~(SYSTEM_CONFIG_SIZE-1)) == SYSTEM_CONFIG_ADDR);

    assign timer_sel = ((cpu_req.addr & ~(TIMER_SIZE-1)) == TIMER_ADDR);

    assign uart_sel = ((cpu_req.addr & ~(UART_SIZE-1)) == UART_ADDR);
    assign port_sel = ((cpu_req.addr & ~(PORT_SIZE-1)) == PORT_ADDR);
    assign video_ram_bus_sel = (cpu_req.addr >= VIDEO_RAM_BUS_ADDR) && (cpu_req.addr < (VIDEO_RAM_BUS_ADDR+VIDEO_RAM_BUS_SIZE));


    // Distribution des requêtes
    always_comb begin
        sram_req                = cpu_req;
        sram_req.select         = cpu_req.select && sram_sel;

        sram_ext_req            = cpu_req;
        sram_ext_req.select     = cpu_req.select && sram_ext_sel;

        system_config_req       = cpu_req;
        system_config_req.select= cpu_req.select && system_config_sel;

        timer_req               = cpu_req;
        timer_req.select        = cpu_req.select && timer_sel;

        uart_req                = cpu_req;
        uart_req.select         = cpu_req.select && uart_sel;

        port_req                = cpu_req;
        port_req.select         = cpu_req.select && port_sel;

        ram_video_req           = cpu_req;
        ram_video_req.select    = cpu_req.select && video_ram_bus_sel;
    end

    // Multiplexage des réponses => CPU
    always_comb begin
        //cpu_resp.rdata = 32'h0;
        //cpu_resp.ready = 1'b0;

        if (sram_sel)
            cpu_resp = sram_resp;
        else if (sram_ext_sel)
            cpu_resp = sram_ext_resp;
        else if (system_config_sel)
            cpu_resp = system_config_resp;
        else if (timer_sel)
            cpu_resp = timer_resp;
        else if (uart_sel)
            cpu_resp = uart_resp;
        else if (port_sel)
            cpu_resp = port_resp;
        else if (video_ram_bus_sel) 
            cpu_resp = ram_video_resp;
        else begin
            // On répond pour ne pas bloquer le CPU
            cpu_resp.rdata = 32'hDEADBEEF; 
            cpu_resp.ready = cpu_req.select; 
        end
    end


endmodule
