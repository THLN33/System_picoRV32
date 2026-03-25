/*
 *  Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module      : timer.sv
 * Description : 32-bit Programmable Timer/Counter for PicoRV32 RISC-V CPU.
 * Supports Up/Down counting modes using a dedicated external 
 * clock (timer_clk) which may be asynchronous to the bus clock.
 *
 * Bus Protocol: PicoRV32 Native Bus Interface (rv32_req_t / rv32_resp_t).
 * Base Address: 0x80000010 (Recommended).
 * ============================================================================
 * Register Map (Offsets from Base Address):
 * ----------------------------------------------------------------------------
 * Offset | Name    | Bits   | Description
 * ----------------------------------------------------------------------------
 * 0x00   | COUNTER | [31:0] | Current Counter Value (R/W).
 *        |         |        | Note: Write only effective when Timer is disabled.
 * 0x04   | RELOAD  | [31:0] | Auto-Reload Value (R/W).
 *        |         |        | Loaded on overflow (UP) or zero (DOWN).
 * 0x08   | CONTROL | [2:0]  | Control Register (R/W):
 *        |         | [0]    | EN: Enable Timer (1=Run, 0=Stop/Pause).
 *        |         | [1]    | MODE: Counting Direction (1=UP, 0=DOWN).
 *        |         | [2]    | IE: Interrupt Enable (1=Enabled, 0=Masked). (not yet supported !)
 * 0x0C   | STATUS  | [0]    | Status Register (R/W1C):
 *        |         | [0]    | IP: Interrupt Pending. Write '1' to clear.
 * ----------------------------------------------------------------------------
 *
 * Clock Domain Crossing (CDC) Implementation:
 * - Control signals (EN, MODE) are synchronized using a 3-stage shift register
 * to the timer_clk domain to prevent metastability.
 * - The event trigger (terminal count) is synchronized back to the bus clock
 * domain (clk) using a rising-edge pulse detector to set the IP flag.
 * - Counter writes utilize a shadow register (tmp_counter) to ensure data 
 * stability during cross-domain transfers.
 *
 * ============================================================================
 */

import picorv32_bus_pkg::*;


`ifdef TN9K
//`define _CLEAR_IRQ_WRITE_STATUS

`else // Others boards 

`endif

`define _ASYNCHONOUS_CLOCK_TIMER

module timer (
        input         reset_n,

        input         clk,              // Horloge Bus (Fast)
        input         timer_clk,        // Horloge de comptage:
                                        // synchrone pour TN9K

        input  rv32_req_t  req,         // Entrée : (Master -> Slave)
        output rv32_resp_t resp,        // Sortie : (Slave -> Master)

        output        irq               // Signal d'interruption vers PicoRV32
);
    // Adresses des registres
    localparam counter_reg_addr_sel     = 3'b100;
    localparam reload_reg_addr_sel      = 3'b101;
    localparam control_reg_addr_sel     = 3'b110;
    localparam status_reg_addr_sel      = 3'b111;

    // Registres
    reg [31:0] tmp_counter;
    reg [31:0] counter;
    reg [31:0] reload;

    // bits du registre control_reg
    reg counter_en;
    reg counter_mode;
    reg enable_irq;

    reg irq_pending;

    // Selection des registres
    wire [2:0] reg_addr_select = {req.select, req.addr[3:2]};

    //assign resp.ready = req.select;
    reg ready = 1'b0;
    always @(posedge clk) 
    if (req.select)
        ready <= 1'b1;
    else
        ready <= 1'b0;
    assign resp.ready = ready;

`ifdef _ASYNCHONOUS_CLOCK_TIMER
    // Not available on TN9K @ 48MHz! 
    // --- Synchronisation CDC (Bus -> Ext_Clk) ---
    reg [2:0] sync_en, sync_mode;
    always @(posedge timer_clk or negedge reset_n) begin
        if (!reset_n) {sync_en, sync_mode} <= 0;
        else begin
            sync_en   <= {sync_en[1:0],   counter_en};
            sync_mode <= {sync_mode[1:0], counter_mode};
        end
    end
    wire active = sync_en[2];
    wire mode   = sync_mode[2];
`else
    wire active = counter_en;
    wire mode = counter_mode;
`endif




    // --- Logique du Compteur (Domaine timer_clk) ---
    reg event_trigger; // Impulsion quand le timer atteint sa cible
    
    always @(posedge timer_clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 32'h0;
            event_trigger <= 1'b0;
        end else begin
            if (active) begin
                if (mode) begin
                    // up counter mode
                    if (counter >= reload) begin
                        counter <= 32'h0;
                        event_trigger <= 1'b1;
                    end else begin
                        counter <= counter + 1;
                        event_trigger <= 1'b0;
                    end
`ifdef _Z
                    if (counter == 32'hFFFF_FFFF) begin
                        counter <= reload;
                        event_trigger <= 1'b1;
                    end else begin
                        counter <= counter + 1;
                        event_trigger <= 1'b0;
                    end
`endif
                end else begin
                    // down counter mode
                    if (counter == 32'h0000_0000) begin
                        counter <= reload;
                        event_trigger <= 1'b1;
                    end else begin
                        counter <= counter - 1;
                        event_trigger <= 1'b0;
                    end
                end
            end else begin
                event_trigger <= 1'b0;
                counter <= tmp_counter;
            end
        end
    end


    // --- Gestion de l'Interruption (Synchronisation timer_clk -> Bus) ---
    reg [2:0] sync_event;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sync_event  <= 3'b0;
            irq_pending <= 1'b0;
        end else begin
            // Capture de l'événement venant de ext_clk
            sync_event <= {sync_event[1:0], event_trigger};
            
            // Détection front montant de l'événement
            if (sync_event[1] && !sync_event[2]) 
                irq_pending <= 1'b1;
            else if (reg_addr_select == status_reg_addr_sel) begin
`ifdef _CLEAR_IRQ_WRITE_STATUS
                if (&req.wstrb) begin
                    // W1C : Clear when write something into status register
                    irq_pending <= 1'b0;
                end
`else
                if (req.wstrb[3] && req.wdata[31]) begin
                    // Clear when write 1 into bit31 of status register  
                    irq_pending <= 1'b0;
                end
`endif
            end
        end
    end

    assign irq = irq_pending && enable_irq; // Sortie IRQ si activée


    // --- Interface de Lecture/Écriture Bus ---
    assign resp.rdata = (reg_addr_select == counter_reg_addr_sel) ? counter :
                        (reg_addr_select == reload_reg_addr_sel) ? reload  :
                        (reg_addr_select == control_reg_addr_sel) ? {irq_pending, 27'b0, event_trigger, enable_irq, counter_mode, counter_en} :
                        (reg_addr_select == status_reg_addr_sel) ? {irq_pending, 31'b0} : 
                        32'hDEAD_BEEF;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            reload  <= 32'h0;
            counter_en <= 1'b0;
            counter_mode <= 1'b0;
            enable_irq <= 1'b0;
        end else if (&req.wstrb) begin

            if (reg_addr_select == counter_reg_addr_sel) begin
                tmp_counter <= req.wdata;
            end
            if (reg_addr_select == reload_reg_addr_sel) begin
                reload  <= req.wdata;
            end;
            if (reg_addr_select == control_reg_addr_sel) begin
                counter_en <= req.wdata[0];
                counter_mode <= req.wdata[1];
                enable_irq <= req.wdata[2];
            end;
        end
    end

endmodule

