/*
 *  Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module      : port.sv
 * Description : 8-bit General Purpose Input/Output (GPIO) Port for PicoRV32.
 * Provides synchronized 8-bit output and asynchronous 8-bit input 
 * reading via the native PicoRV32 bus interface.
 *
 * Bus Protocol: PicoRV32 Native Bus Interface (rv32_req_t / rv32_resp_t).
 * Register Alignment: 32-bit word aligned (Address bit [2] used for selection).
 * ============================================================================
 * Register Map (Offsets from Base Address):
 * ----------------------------------------------------------------------------
 * Offset | Name     | Access | Description
 * ----------------------------------------------------------------------------
 * 0x00   | PORT_OUT | R/W    | Output Port Register (Bits [7:0]).
 *        |          |        | Writing updates the physical output pins.
 *        |          |        | Reading returns the last value written.
 * 0x04   | PORT_IN  | RO     | Input Port Register (Bits [7:0]).
 *        |          |        | Reading returns the current state of physical pins.
 * ----------------------------------------------------------------------------
 *
 * Implementation Details:
 * - Bus Synchronization: 'resp.ready' is asserted one clock cycle after 
 * 'req.select' to meet the native bus handshake requirements.
 * - Write Masking: Output register update is gated by 'req.wstrb[0]', 
 * allowing byte-level access from the CPU.
 * - Clock Domain: Entirely synchronous to the 'clk' domain.
 *
 * ============================================================================
 */
import picorv32_bus_pkg::*;


module port_inout (
        input wire         clk,
        input wire         reset_n,

        input  rv32_req_t  req,     // Entrée : (Master -> Slave)
        output rv32_resp_t resp,    // Sortie : (Slave -> Master)

        input wire [7:0]   port_in,    
        output reg [7:0]   port_out
    );


    wire [1:0] reg_select = {req.select, req.addr[2]};

    assign resp.rdata = (reg_select == 2'b10) ? {26'h0000_00, port_out} :
                        (reg_select == 2'b11) ? {26'h0000_00, port_in} :
                         {32'h0000_0000};

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
            port_out <= 8'h00;
        end else begin
            if ((reg_select==2'b10) && (req.wstrb[0])) begin
                port_out <= req.wdata;
            end
        end               
    end

endmodule // port_inout
