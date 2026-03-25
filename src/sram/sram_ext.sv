/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module : sram_ext.sv
 * Description : This module defines a scalable External SRAM interface composed 
 * of up to 8 memory banks (8 x 8KB = 64KB Max capacity).
 *
 * ============================================================================
 * IO Description:
 * - clk		    : System Clock.
 * - resetn		    : Active-low Reset.
 * - sram_sel       : Chip Select to enable the SRAM module.
 * - wstrb [3:0]    : Write Strobe for byte-level write masking (32-bit word).
 * - addr [15:0]    : 16-bit Address bus (supporting the full 64KB range).
 * - sram_data_i/o  : 32-bit Data Input/Output buses.
 * - sram_ready     : Handshake signal indicating operation completion.
 * ============================================================================
 *
 */
import picorv32_bus_pkg::*;

/**
    8 X sram_bank => 8 x 8KB = 64KB Max
*/

//`define SRAM_EXT_64K
//`define SRAM_EXT_56K
//`define SRAM_EXT_48K
//`define SRAM_EXT_36K
//`define SRAM_EXT_32K
//`define SRAM_EXT_24K
//`define SRAM_EXT_16K
//`define SRAM_EXT_8K

`ifdef SRAM_EXT_64K
    `define BLOCK_0
    `define BLOCK_1
    `define BLOCK_2
    `define BLOCK_3
    `define BLOCK_4
    `define BLOCK_5
    `define BLOCK_6
    `define BLOCK_7
`endif
`ifdef SRAM_EXT_56K
    `define BLOCK_0
    `define BLOCK_1
    `define BLOCK_2
    `define BLOCK_3
    `define BLOCK_4
    `define BLOCK_5
    `define BLOCK_6
    `undef BLOCK_7
`endif
`ifdef SRAM_EXT_48K
    `define BLOCK_0
    `define BLOCK_1
    `define BLOCK_2
    `define BLOCK_3
    `define BLOCK_4
    `define BLOCK_5
    `undef BLOCK_6
    `undef BLOCK_7
`endif
`ifdef SRAM_EXT_36K
    `define BLOCK_0
    `define BLOCK_1
    `define BLOCK_2
    `define BLOCK_3
    `define BLOCK_4
    `undef BLOCK_5
    `undef BLOCK_6
    `undef BLOCK_7
`endif
`ifdef SRAM_EXT_32K
    `define BLOCK_0
    `define BLOCK_1
    `define BLOCK_2
    `define BLOCK_3
    `undef BLOCK_4
    `undef BLOCK_5
    `undef BLOCK_6
    `undef BLOCK_7
`endif
`ifdef SRAM_EXT_24K
    `define BLOCK_0
    `define BLOCK_1
    `define BLOCK_2
    `undef BLOCK_3
    `undef BLOCK_4
    `undef BLOCK_5
    `undef BLOCK_6
    `undef BLOCK_7
`endif
`ifdef SRAM_EXT_18K
    `define BLOCK_0
    `define BLOCK_1
    `define BLOCK_2
    `undef BLOCK_3
    `undef BLOCK_4
    `undef BLOCK_5
    `undef BLOCK_6
    `undef BLOCK_7
`endif
`ifdef SRAM_EXT_16K
    `define BLOCK_0
    `define BLOCK_1
    `undef BLOCK_2
    `undef BLOCK_3
    `undef BLOCK_4
    `undef BLOCK_5
    `undef BLOCK_6
    `undef BLOCK_7
`endif
`ifdef SRAM_EXT_8K
    `define BLOCK_0
    `undef BLOCK_1
    `undef BLOCK_2
    `undef BLOCK_3
    `undef BLOCK_4
    `undef BLOCK_5
    `undef BLOCK_6
    `undef BLOCK_7
`endif


module sram_ext (
        input wire                 clk,
        input wire                 resetn,


        input  rv32_req_t  req,     // Entrée : (Master -> Slave)
        output rv32_resp_t resp     // Sortie : (Slave -> Master)
    );



`ifdef BLOCK_0
    wire sram_sel_0;
    assign sram_sel_0 = (req.addr[15:13]==3'd0) & req.select;

    wire [31:0] sram_blk0_data_o;    
`endif
`ifdef BLOCK_1
    wire sram_sel_1;
    assign sram_sel_1 = (req.addr[15:13]==3'd1) & req.select;

    wire [31:0] sram_blk1_data_o; 
`endif
`ifdef BLOCK_2
    wire sram_sel_2;
    assign sram_sel_2 = (req.addr[15:13]==3'd2) & req.select;

    wire [31:0] sram_blk2_data_o; 
`endif
`ifdef BLOCK_3
    wire sram_sel_3;
    assign sram_sel_3 = (req.addr[15:13]==3'd3) & req.select;

    wire [31:0] sram_blk3_data_o; 
`endif
`ifdef BLOCK_4
    wire sram_sel_4;
    assign sram_sel_4 = (req.addr[15:13]==3'd4) & req.select;

    wire [31:0] sram_blk4_data_o; 
`endif
`ifdef BLOCK_5
    wire sram_sel_5;
    assign sram_sel_5 = (req.addr[15:13]==3'd5) & req.select;

    wire [31:0] sram_blk5_data_o; 
`endif
`ifdef BLOCK_6
    wire sram_sel_6;
    assign sram_sel_6 = (req.addr[15:13]==3'd6) & req.select;

    wire [31:0] sram_blk6_data_o; 
`endif
`ifdef BLOCK_7
    wire sram_sel_7;
    assign sram_sel_7 = (req.addr[15:13]==3'd7) & req.select;

    wire [31:0] sram_blk7_data_o; 
`endif


    assign resp.rdata = 
`ifdef BLOCK_0
                         sram_sel_0 ? sram_blk0_data_o :
`endif
`ifdef BLOCK_1
                         sram_sel_1 ? sram_blk1_data_o :
`endif
`ifdef BLOCK_2
                         sram_sel_2 ? sram_blk2_data_o :
`endif
`ifdef BLOCK_3
                         sram_sel_3 ? sram_blk3_data_o :
`endif
`ifdef BLOCK_4
                         sram_sel_4 ? sram_blk4_data_o :
`endif
`ifdef BLOCK_5
                         sram_sel_5 ? sram_blk5_data_o :
`endif
`ifdef BLOCK_6
                         sram_sel_6 ? sram_blk6_data_o :
`endif
`ifdef BLOCK_7
                         sram_sel_7 ? sram_blk7_data_o :
`endif
                         32'h0;



`ifdef BLOCK_0
    sram_bank #(.ADDRWIDTH(13)) sram_bank0 (
        .clk(clk),
        .resetn(resetn),
        .sram_sel(sram_sel_0),
        .wstrb(req.wstrb),
        .addr(req.addr[12:0]),
        .sram_data_i(req.wdata),
        .sram_data_o(sram_blk0_data_o)
    );
`endif
`ifdef BLOCK_1
    sram_bank #(.ADDRWIDTH(13)) sram_bank1 (
        .clk(clk),
        .resetn(resetn),
        .sram_sel(sram_sel_1),
        .wstrb(req.wstrb),
        .addr(req.addr[12:0]),
        .sram_data_i(req.wdata),
        .sram_data_o(sram_blk1_data_o)
    );
`endif
`ifdef BLOCK_2
    sram_bank #(.ADDRWIDTH(13)) sram_bank2 (
        .clk(clk),
        .resetn(resetn),
        .sram_sel(sram_sel_2),
        .wstrb(req.wstrb),
        .addr(req.addr[12:0]),
        .sram_data_i(req.wdata),
        .sram_data_o(sram_blk2_data_o)
    );
`endif
`ifdef BLOCK_3
    sram_bank #(.ADDRWIDTH(13)) sram_bank3 (
        .clk(clk),
        .resetn(resetn),
        .sram_sel(sram_sel_3),
        .wstrb(req.wstrb),
        .addr(req.addr[12:0]),
        .sram_data_i(req.wdata),
        .sram_data_o(sram_blk3_data_o)
    );
`endif
`ifdef BLOCK_4
    sram_bank #(.ADDRWIDTH(13)) sram_bank4 (
        .clk(clk),
        .resetn(resetn),
        .sram_sel(sram_sel_4),
        .wstrb(req.wstrb),
        .addr(req.addr[12:0]),
        .sram_data_i(req.wdata),
        .sram_data_o(sram_blk4_data_o)
    );
`endif
`ifdef BLOCK_5
    sram_bank #(.ADDRWIDTH(13)) sram_bank5 (
        .clk(clk),
        .resetn(resetn),
        .sram_sel(sram_sel_5),
        .wstrb(req.wstrb),
        .addr(req.addr[12:0]),
        .sram_data_i(req.wdata),
        .sram_data_o(sram_blk5_data_o)
    );
`endif
`ifdef BLOCK_6
    sram_bank #(.ADDRWIDTH(13)) sram_bank6 (
        .clk(clk),
        .resetn(resetn),
        .sram_sel(sram_sel_6),
        .wstrb(req.wstrb),
        .addr(req.addr[12:0]),
        .sram_data_i(req.wdata),
        .sram_data_o(sram_blk6_data_o)
    );
`endif
`ifdef BLOCK_7
    sram_bank #(.ADDRWIDTH(13)) sram_bank7 (
        .clk(clk),
        .resetn(resetn),
        .sram_sel(sram_sel_7),
        .wstrb(req.wstrb),
        .addr(req.addr[12:0]),
        .sram_data_i(req.wdata),
        .sram_data_o(sram_blk7_data_o)
    );
`endif


    reg ready = 1'b0;
    always @(posedge clk) 
    if (req.select)
        ready <= 1'b1;
    else
        ready <= 1'b0;
    assign resp.ready = ready;

endmodule   // sram_ext