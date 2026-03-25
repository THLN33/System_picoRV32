/*
 *  Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module      : system_config
 * Description : System Configuration and Hardware Identification Module.
 * Provides read-only identification registers and a writeable 
 * clock configuration register for global system control.
 *
 * Bus Protocol: PicoRV32 Native Bus Interface (rv32_req_t / rv32_resp_t).
 * Register Alignment: 32-bit word aligned (Address bits [3:2] used).
 * ============================================================================
 * Parameters:
 * - init_word_ident0 : Default magic word or hardware ID 0.
 * - init_word_ident1 : Default magic word or hardware ID 1.
 * ============================================================================
 * Register Map (Offsets from Base Address):
 * ----------------------------------------------------------------------------
 * Offset | Name   | Access | Description
 * ----------------------------------------------------------------------------
 * 0x00   | IDENT0 | RO* | Identification Word 0 (e.g., 0x5555AAAA).
 * 0x04   | IDENT1 | RO* | Identification Word 1 (e.g., 0xAAAA5555).
 * 0x08   | CLKREG | R/W    | Clock Control Register:
 *        |        |        | [1:0] : Selection bits for system clock frequency.
 *        |        |        | Default: 2'b00 (24 MHz).
 * ----------------------------------------------------------------------------
 * *Note: IDENT registers are technically writable in this specific Verilog 
 * implementation but behave as constants initialized by parameters.
 *
 * Implementation Details:
 * - Handshake: 'resp.ready' follows 'req.select' with 1-cycle latency.
 * - Write Protection: 'clkreg' update is gated by 'req.wstrb[0]'.
 * - Default Values: Parameters allow customizing IDs per hardware build.
 *
 * ============================================================================
 */
import picorv32_bus_pkg::*;


module system_config #(
        parameter init_word_ident0 = 32'h5555AAAA,
        parameter init_word_ident1 = 32'hAAAA5555
)(
        input wire          clk,
        input wire          reset_n,

        input  rv32_req_t   req,     // Entrée : (Master -> Slave)
        output rv32_resp_t  resp,    // Sortie : (Slave -> Master)

        output reg [31:0]   word_ident0,
        output reg [31:0]   word_ident1,

        output reg [1:0]    clkreg

    );


    wire [2:0] reg_select = {req.select, req.addr[3:2]};

    assign resp.rdata = (reg_select == 3'b100) ? word_ident0 :
                        (reg_select == 3'b101) ? word_ident1 :
                        (reg_select == 3'b110) ? {30'b0, clkreg[1:0]} :
                         {32'hDEAD_BEEF};

    //assign resp.ready = req.select;
    reg ready = 1'b0;
    always @(posedge clk) 
    if (req.select)
        ready <= 1'b1;
    else
        ready <= 1'b0;
    assign resp.ready = ready;


    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            word_ident0 <= init_word_ident0;
            word_ident1 <= init_word_ident1;
            clkreg <= 2'b00; // default : 12 MHz
            //clkreg <= 2'b01; // default : 48 MHz
            //clkreg <= 2'b10; // default : 60 MHz
        end else begin

            if ((reg_select==3'b110) && (req.wstrb[0])) begin
                clkreg <= req.wdata[1:0];
            end

        end               
    end

endmodule // system_config


