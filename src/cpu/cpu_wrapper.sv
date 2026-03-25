/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module      : picorv32_wrapper
 * Description : Structural Wrapper for the PicoRV32 RISC-V CPU Core.
 * Adapts the native PicoRV32 memory interface into a structured bus protocol
 * (rv32_req_t / rv32_resp_t) used throughout the SoC.
 *
 * Architecture:
 * - CPU Core: PicoRV32 (Size-optimized RISC-V RV32IM implementation).
 * - Protocol: Custom structured Request/Response bus wrapper.
 * ============================================================================
 * Implementation Details:
 * - Signal Mapping: Maps 'mem_valid' to 'req_out.select' and 'mem_ready' 
 * to 'resp_in.ready' to drive the bus handshake.
 * - Interrupts: Hardware IRQ support is enabled, currently tied to 32'b0.
 * - Instruction/Data: Uses a unified memory interface for both instruction 
 * fetches and data load/stores.
 *
 * ============================================================================
 */
import picorv32_bus_pkg::*;

module picorv32_wrapper (
        input  logic      clk,
        input  logic      reset_n,

        // Nos nouveaux ports structurés
        output rv32_req_t  req_out,
        input  rv32_resp_t resp_in
    );

    parameter [0:0] BARREL_SHIFTER = 0;
    parameter [0:0] ENABLE_MUL = 0;
    parameter [0:0] ENABLE_DIV = 1;
    parameter [0:0] ENABLE_FAST_MUL = 1;
    parameter [0:0] ENABLE_COMPRESSED = 0;
    parameter [0:0] ENABLE_IRQ_QREGS = 1;

    parameter MEMBYTES = 8192;
    parameter [31:0] STACKADDR = (MEMBYTES);            // Software should set it on start.S
    parameter [31:0] PROGADDR_RESET = 32'h0000_0000;
    parameter [31:0] PROGADDR_IRQ = 32'h0000_0010;      // when using IRQ

    // Instance de l'IP PicoRV32 (Verilog natif)
    picorv32 #(
        .STACKADDR(STACKADDR),
        .PROGADDR_RESET(PROGADDR_RESET),
        .PROGADDR_IRQ(PROGADDR_IRQ),
        .BARREL_SHIFTER(BARREL_SHIFTER),
        .COMPRESSED_ISA(ENABLE_COMPRESSED),
        .ENABLE_MUL(ENABLE_MUL),
        .ENABLE_DIV(ENABLE_DIV),
        .ENABLE_FAST_MUL(ENABLE_FAST_MUL),
        .ENABLE_IRQ(1),
        .ENABLE_IRQ_QREGS(ENABLE_IRQ_QREGS),
        .ENABLE_REGS_16_31(1),
        .ENABLE_COUNTERS(1)
    ) cpu (
        .clk         (clk),
        .resetn      (reset_n),

        // Sorties du CPU -> On les range dans la structure req_out
        .mem_valid   (req_out.select), // On utilise 'select' pour 'valid'
        .mem_instr   (),               // Non utilisé ici
        .mem_addr    (req_out.addr),
        .mem_wdata   (req_out.wdata),
        .mem_wstrb   (req_out.wstrb),
        
        // Entrées du CPU <- On les lit depuis la structure resp_in
        .mem_ready   (resp_in.ready),
        .mem_rdata   (resp_in.rdata),

        // Signaux d'interruption (mis à 0 si non utilisés)
        .irq         (32'b0)
    );




endmodule