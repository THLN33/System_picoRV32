/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module      : sram_bank
 * Description : Generic 32-bit Static RAM Bank.
 * A modular memory component composed of four 8-bit wide Gowin BSRAMs. 
 * This module provides byte-addressable read/write access, making it 
 * compatible with RISC-V memory instructions (LB, LH, LW, SB, SH, SW).
 *
 * ============================================================================
 * Parameters:
 * - ADDRWIDTH : 13 bits (Default). Defines the addressable range.
 * ============================================================================
 * IO Description:
 * - clk       : System clock.
 * - resetn    : Active-low synchronous reset.
 * - req       : rv32_req_t structure (Master -> Slave).
 * - resp      : rv32_resp_t structure (Slave -> Master).
 * ============================================================================
 * Design Notes:
 * 1. Word Alignment: 'addr[12:2]' is used for the primitive 'ad' input to 
 * select the 32-bit word, while 'wstrb' handles byte-level granularity.
 * 2. Resource Usage: Utilizes 4 Single-Port BSRAM (Gowin_SP) primitives.
 * 3. Scalability: This module can be instantiated in a "Memory Array" to 
 * create larger RAM sections (e.g., 16KB, 32KB) via an interconnect.
 * ============================================================================
 */



/**
    BRAM size => 16384 x 1 bit = 2048 x 8 bits = 2KB
    
    4 BRAM => 8KB 
*/
module sram_bank #(parameter ADDRWIDTH=13) (
        input wire                 clk,
        input wire                 resetn,
        input wire                 sram_sel,
        input wire [3:0]           wstrb,
        input wire [ADDRWIDTH-1:0] addr,
        input wire [31:0]          sram_data_i,
        output wire [31:0]         sram_data_o
    );


    Gowin_SP gw_mem3 (
        .dout(sram_data_o[31:24]),
        .clk(clk),
        .oce(1'b1),
        .ce(sram_sel),
        .reset(~resetn),
        .wre(wstrb[3]),
        .ad(addr[12:2]),
        .din(sram_data_i[31:24])
    );

   Gowin_SP gw_mem2 (
        .dout(sram_data_o[23:16]),
        .clk(clk),
        .oce(1'b1),
        .ce(sram_sel),
        .reset(~resetn),
        .wre(wstrb[2]),
        .ad(addr[12:2]),
        .din(sram_data_i[23:16])
    );

   Gowin_SP gw_mem1 (
        .dout(sram_data_o[15:8]),
        .clk(clk),
        .oce(1'b1),
        .ce(sram_sel),
        .reset(~resetn),
        .wre(wstrb[1]),
        .ad(addr[12:2]),
        .din(sram_data_i[15:8])
    );

   Gowin_SP gw_mem0 (
        .dout(sram_data_o[7:0]),
        .clk(clk),
        .oce(1'b1),
        .ce(sram_sel),
        .reset(~resetn),
        .wre(wstrb[0]),
        .ad(addr[12:2]),
        .din(sram_data_i[7:0])
    );

endmodule   // sram_bank