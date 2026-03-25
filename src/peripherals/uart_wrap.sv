import picorv32_bus_pkg::*;

module uart_wrap (
        input wire         clk,
        input wire         reset_n,


        input  rv32_req_t  req,     // Entrée : (Master -> Slave)
        output rv32_resp_t resp,    // Sortie : (Slave -> Master)

        input wire         uart_rx,
        output wire        uart_tx
    );

/*
    wire [2:0] reg_select = {req.select, req.addr[3:2]};


    assign resp.rdata = (reg_select == 3'b100) ? divider_reg :
                        (reg_select == 3'b101) ? data_reg :
                        {32'hDEAD_BEEF};
*/


   wire               div_sel;
   wire               dat_sel;
   wire [31:0]        div_do;
   wire [31:0]        dat_do;
   wire               dat_wait;
            


   assign div_sel = req.select && (req.addr[3:0] == 4'h8);
   assign dat_sel = req.select && (req.addr[3:0] == 4'hc);
   assign resp.rdata =  div_sel ? div_do :
                        dat_sel ? dat_do : 
                        32'h0;

   assign resp.ready = div_sel | (dat_sel && !dat_wait);
   
    simpleuart simpleuart_inst0 (
        .resetn(reset_n),

        .clk(clk),

        .ser_tx(uart_tx),
        .ser_rx(uart_rx),

        .reg_div_we(div_sel ? req.wstrb : 4'b0000),
        .reg_div_di(req.wdata),
        .reg_div_do(div_do),
        .reg_dat_we(dat_sel ? req.wstrb[0] : 1'b0),
        .reg_dat_re(dat_sel && !req.wstrb),
        .reg_dat_di(req.wdata),
        .reg_dat_do(dat_do),
        .reg_dat_wait(dat_wait)
    );

endmodule
