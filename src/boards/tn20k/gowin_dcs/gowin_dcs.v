//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12 (64-bit)
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Fri Mar 13 11:39:57 2026

module Gowin_DCS (
        output          clkout, 
        input [1:0]     clkreg, 
        input           clkin0, 
        input           clkin1, 
        input           clkin2, 
        input           clkin3
    );


wire [3:0] clksel;
assign clksel = (clkreg == 2'b00) ? 4'b0001 :
                (clkreg == 2'b01) ? 4'b0010 :   
                (clkreg == 2'b10) ? 4'b0100 :   
                (clkreg == 2'b11) ? 4'b1000 : 
                4'b0001;   
wire gw_gnd;
assign gw_gnd = 1'b0;

DCS dcs_inst (
    .CLKOUT(clkout),
    .CLKSEL(clksel),
    .CLK0(clkin0),
    .CLK1(clkin1),
    .CLK2(clkin2),
    .CLK3(clkin3),
    .SELFORCE(gw_gnd)
);

defparam dcs_inst.DCS_MODE = "RISING";

endmodule //Gowin_DCS
