//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12 (64-bit)
//Part Number: GW5A-LV25MG121NC1/I0
//Device: GW5A-25
//Device Version: A
//Created Time: Fri Mar 13 09:03:02 2026

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
    .CLKIN0(clkin0),
    .CLKIN1(clkin1),
    .CLKIN2(clkin2),
    .CLKIN3(clkin3),
    .SELFORCE(gw_gnd)       // 0: Glitchless mode
);

defparam dcs_inst.DCS_MODE = "RISING";

endmodule //Gowin_DCS
