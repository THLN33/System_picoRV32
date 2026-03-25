//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12 (64-bit)
//Part Number: GW5A-LV25MG121NC1/I0
//Device: GW5A-25
//Device Version: A
//Created Time: Thu Mar  5 20:55:52 2026

module Gowin_VRAM_DPB (douta, doutb, clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb, ada, dina, adb, dinb);

output [17:0] douta;
output [17:0] doutb;
input clka;
input ocea;
input cea;
input reseta;
input wrea;
input clkb;
input oceb;
input ceb;
input resetb;
input wreb;
input [11:0] ada;
input [17:0] dina;
input [11:0] adb;
input [17:0] dinb;

wire [8:0] dpx9b_inst_0_douta_w;
wire [8:0] dpx9b_inst_0_douta;
wire [8:0] dpx9b_inst_0_doutb_w;
wire [8:0] dpx9b_inst_0_doutb;
wire [8:0] dpx9b_inst_1_douta_w;
wire [8:0] dpx9b_inst_1_douta;
wire [8:0] dpx9b_inst_1_doutb_w;
wire [8:0] dpx9b_inst_1_doutb;
wire [8:0] dpx9b_inst_2_douta_w;
wire [17:9] dpx9b_inst_2_douta;
wire [8:0] dpx9b_inst_2_doutb_w;
wire [17:9] dpx9b_inst_2_doutb;
wire [8:0] dpx9b_inst_3_douta_w;
wire [17:9] dpx9b_inst_3_douta;
wire [8:0] dpx9b_inst_3_doutb_w;
wire [17:9] dpx9b_inst_3_doutb;
wire dff_q_0;
wire dff_q_1;
wire cea_w;
wire ceb_w;
wire gw_gnd;

assign cea_w = ~wrea & cea;
assign ceb_w = ~wreb & ceb;
assign gw_gnd = 1'b0;

DPX9B dpx9b_inst_0 (
    .DOA({dpx9b_inst_0_douta_w[8:0],dpx9b_inst_0_douta[8:0]}),
    .DOB({dpx9b_inst_0_doutb_w[8:0],dpx9b_inst_0_doutb[8:0]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[11]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[11]}),
    .ADA({ada[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[8:0]}),
    .ADB({adb[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[8:0]})
);

defparam dpx9b_inst_0.READ_MODE0 = 1'b0;
defparam dpx9b_inst_0.READ_MODE1 = 1'b0;
defparam dpx9b_inst_0.WRITE_MODE0 = 2'b00;
defparam dpx9b_inst_0.WRITE_MODE1 = 2'b00;
defparam dpx9b_inst_0.BIT_WIDTH_0 = 9;
defparam dpx9b_inst_0.BIT_WIDTH_1 = 9;
defparam dpx9b_inst_0.BLK_SEL_0 = 3'b000;
defparam dpx9b_inst_0.BLK_SEL_1 = 3'b000;
defparam dpx9b_inst_0.RESET_MODE = "SYNC";

DPX9B dpx9b_inst_1 (
    .DOA({dpx9b_inst_1_douta_w[8:0],dpx9b_inst_1_douta[8:0]}),
    .DOB({dpx9b_inst_1_doutb_w[8:0],dpx9b_inst_1_doutb[8:0]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[11]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[11]}),
    .ADA({ada[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[8:0]}),
    .ADB({adb[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[8:0]})
);

defparam dpx9b_inst_1.READ_MODE0 = 1'b0;
defparam dpx9b_inst_1.READ_MODE1 = 1'b0;
defparam dpx9b_inst_1.WRITE_MODE0 = 2'b00;
defparam dpx9b_inst_1.WRITE_MODE1 = 2'b00;
defparam dpx9b_inst_1.BIT_WIDTH_0 = 9;
defparam dpx9b_inst_1.BIT_WIDTH_1 = 9;
defparam dpx9b_inst_1.BLK_SEL_0 = 3'b001;
defparam dpx9b_inst_1.BLK_SEL_1 = 3'b001;
defparam dpx9b_inst_1.RESET_MODE = "SYNC";

DPX9B dpx9b_inst_2 (
    .DOA({dpx9b_inst_2_douta_w[8:0],dpx9b_inst_2_douta[17:9]}),
    .DOB({dpx9b_inst_2_doutb_w[8:0],dpx9b_inst_2_doutb[17:9]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[11]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[11]}),
    .ADA({ada[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[17:9]}),
    .ADB({adb[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[17:9]})
);

defparam dpx9b_inst_2.READ_MODE0 = 1'b0;
defparam dpx9b_inst_2.READ_MODE1 = 1'b0;
defparam dpx9b_inst_2.WRITE_MODE0 = 2'b00;
defparam dpx9b_inst_2.WRITE_MODE1 = 2'b00;
defparam dpx9b_inst_2.BIT_WIDTH_0 = 9;
defparam dpx9b_inst_2.BIT_WIDTH_1 = 9;
defparam dpx9b_inst_2.BLK_SEL_0 = 3'b000;
defparam dpx9b_inst_2.BLK_SEL_1 = 3'b000;
defparam dpx9b_inst_2.RESET_MODE = "SYNC";

DPX9B dpx9b_inst_3 (
    .DOA({dpx9b_inst_3_douta_w[8:0],dpx9b_inst_3_douta[17:9]}),
    .DOB({dpx9b_inst_3_doutb_w[8:0],dpx9b_inst_3_doutb[17:9]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[11]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[11]}),
    .ADA({ada[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[17:9]}),
    .ADB({adb[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[17:9]})
);

defparam dpx9b_inst_3.READ_MODE0 = 1'b0;
defparam dpx9b_inst_3.READ_MODE1 = 1'b0;
defparam dpx9b_inst_3.WRITE_MODE0 = 2'b00;
defparam dpx9b_inst_3.WRITE_MODE1 = 2'b00;
defparam dpx9b_inst_3.BIT_WIDTH_0 = 9;
defparam dpx9b_inst_3.BIT_WIDTH_1 = 9;
defparam dpx9b_inst_3.BLK_SEL_0 = 3'b001;
defparam dpx9b_inst_3.BLK_SEL_1 = 3'b001;
defparam dpx9b_inst_3.RESET_MODE = "SYNC";

DFFRE dff_inst_0 (
  .Q(dff_q_0),
  .D(ada[11]),
  .CLK(clka),
  .CE(cea_w),
  .RESET(gw_gnd)
);
DFFRE dff_inst_1 (
  .Q(dff_q_1),
  .D(adb[11]),
  .CLK(clkb),
  .CE(ceb_w),
  .RESET(gw_gnd)
);
MUX2 mux_inst_0 (
  .O(douta[0]),
  .I0(dpx9b_inst_0_douta[0]),
  .I1(dpx9b_inst_1_douta[0]),
  .S0(dff_q_0)
);
MUX2 mux_inst_1 (
  .O(douta[1]),
  .I0(dpx9b_inst_0_douta[1]),
  .I1(dpx9b_inst_1_douta[1]),
  .S0(dff_q_0)
);
MUX2 mux_inst_2 (
  .O(douta[2]),
  .I0(dpx9b_inst_0_douta[2]),
  .I1(dpx9b_inst_1_douta[2]),
  .S0(dff_q_0)
);
MUX2 mux_inst_3 (
  .O(douta[3]),
  .I0(dpx9b_inst_0_douta[3]),
  .I1(dpx9b_inst_1_douta[3]),
  .S0(dff_q_0)
);
MUX2 mux_inst_4 (
  .O(douta[4]),
  .I0(dpx9b_inst_0_douta[4]),
  .I1(dpx9b_inst_1_douta[4]),
  .S0(dff_q_0)
);
MUX2 mux_inst_5 (
  .O(douta[5]),
  .I0(dpx9b_inst_0_douta[5]),
  .I1(dpx9b_inst_1_douta[5]),
  .S0(dff_q_0)
);
MUX2 mux_inst_6 (
  .O(douta[6]),
  .I0(dpx9b_inst_0_douta[6]),
  .I1(dpx9b_inst_1_douta[6]),
  .S0(dff_q_0)
);
MUX2 mux_inst_7 (
  .O(douta[7]),
  .I0(dpx9b_inst_0_douta[7]),
  .I1(dpx9b_inst_1_douta[7]),
  .S0(dff_q_0)
);
MUX2 mux_inst_8 (
  .O(douta[8]),
  .I0(dpx9b_inst_0_douta[8]),
  .I1(dpx9b_inst_1_douta[8]),
  .S0(dff_q_0)
);
MUX2 mux_inst_9 (
  .O(douta[9]),
  .I0(dpx9b_inst_2_douta[9]),
  .I1(dpx9b_inst_3_douta[9]),
  .S0(dff_q_0)
);
MUX2 mux_inst_10 (
  .O(douta[10]),
  .I0(dpx9b_inst_2_douta[10]),
  .I1(dpx9b_inst_3_douta[10]),
  .S0(dff_q_0)
);
MUX2 mux_inst_11 (
  .O(douta[11]),
  .I0(dpx9b_inst_2_douta[11]),
  .I1(dpx9b_inst_3_douta[11]),
  .S0(dff_q_0)
);
MUX2 mux_inst_12 (
  .O(douta[12]),
  .I0(dpx9b_inst_2_douta[12]),
  .I1(dpx9b_inst_3_douta[12]),
  .S0(dff_q_0)
);
MUX2 mux_inst_13 (
  .O(douta[13]),
  .I0(dpx9b_inst_2_douta[13]),
  .I1(dpx9b_inst_3_douta[13]),
  .S0(dff_q_0)
);
MUX2 mux_inst_14 (
  .O(douta[14]),
  .I0(dpx9b_inst_2_douta[14]),
  .I1(dpx9b_inst_3_douta[14]),
  .S0(dff_q_0)
);
MUX2 mux_inst_15 (
  .O(douta[15]),
  .I0(dpx9b_inst_2_douta[15]),
  .I1(dpx9b_inst_3_douta[15]),
  .S0(dff_q_0)
);
MUX2 mux_inst_16 (
  .O(douta[16]),
  .I0(dpx9b_inst_2_douta[16]),
  .I1(dpx9b_inst_3_douta[16]),
  .S0(dff_q_0)
);
MUX2 mux_inst_17 (
  .O(douta[17]),
  .I0(dpx9b_inst_2_douta[17]),
  .I1(dpx9b_inst_3_douta[17]),
  .S0(dff_q_0)
);
MUX2 mux_inst_18 (
  .O(doutb[0]),
  .I0(dpx9b_inst_0_doutb[0]),
  .I1(dpx9b_inst_1_doutb[0]),
  .S0(dff_q_1)
);
MUX2 mux_inst_19 (
  .O(doutb[1]),
  .I0(dpx9b_inst_0_doutb[1]),
  .I1(dpx9b_inst_1_doutb[1]),
  .S0(dff_q_1)
);
MUX2 mux_inst_20 (
  .O(doutb[2]),
  .I0(dpx9b_inst_0_doutb[2]),
  .I1(dpx9b_inst_1_doutb[2]),
  .S0(dff_q_1)
);
MUX2 mux_inst_21 (
  .O(doutb[3]),
  .I0(dpx9b_inst_0_doutb[3]),
  .I1(dpx9b_inst_1_doutb[3]),
  .S0(dff_q_1)
);
MUX2 mux_inst_22 (
  .O(doutb[4]),
  .I0(dpx9b_inst_0_doutb[4]),
  .I1(dpx9b_inst_1_doutb[4]),
  .S0(dff_q_1)
);
MUX2 mux_inst_23 (
  .O(doutb[5]),
  .I0(dpx9b_inst_0_doutb[5]),
  .I1(dpx9b_inst_1_doutb[5]),
  .S0(dff_q_1)
);
MUX2 mux_inst_24 (
  .O(doutb[6]),
  .I0(dpx9b_inst_0_doutb[6]),
  .I1(dpx9b_inst_1_doutb[6]),
  .S0(dff_q_1)
);
MUX2 mux_inst_25 (
  .O(doutb[7]),
  .I0(dpx9b_inst_0_doutb[7]),
  .I1(dpx9b_inst_1_doutb[7]),
  .S0(dff_q_1)
);
MUX2 mux_inst_26 (
  .O(doutb[8]),
  .I0(dpx9b_inst_0_doutb[8]),
  .I1(dpx9b_inst_1_doutb[8]),
  .S0(dff_q_1)
);
MUX2 mux_inst_27 (
  .O(doutb[9]),
  .I0(dpx9b_inst_2_doutb[9]),
  .I1(dpx9b_inst_3_doutb[9]),
  .S0(dff_q_1)
);
MUX2 mux_inst_28 (
  .O(doutb[10]),
  .I0(dpx9b_inst_2_doutb[10]),
  .I1(dpx9b_inst_3_doutb[10]),
  .S0(dff_q_1)
);
MUX2 mux_inst_29 (
  .O(doutb[11]),
  .I0(dpx9b_inst_2_doutb[11]),
  .I1(dpx9b_inst_3_doutb[11]),
  .S0(dff_q_1)
);
MUX2 mux_inst_30 (
  .O(doutb[12]),
  .I0(dpx9b_inst_2_doutb[12]),
  .I1(dpx9b_inst_3_doutb[12]),
  .S0(dff_q_1)
);
MUX2 mux_inst_31 (
  .O(doutb[13]),
  .I0(dpx9b_inst_2_doutb[13]),
  .I1(dpx9b_inst_3_doutb[13]),
  .S0(dff_q_1)
);
MUX2 mux_inst_32 (
  .O(doutb[14]),
  .I0(dpx9b_inst_2_doutb[14]),
  .I1(dpx9b_inst_3_doutb[14]),
  .S0(dff_q_1)
);
MUX2 mux_inst_33 (
  .O(doutb[15]),
  .I0(dpx9b_inst_2_doutb[15]),
  .I1(dpx9b_inst_3_doutb[15]),
  .S0(dff_q_1)
);
MUX2 mux_inst_34 (
  .O(doutb[16]),
  .I0(dpx9b_inst_2_doutb[16]),
  .I1(dpx9b_inst_3_doutb[16]),
  .S0(dff_q_1)
);
MUX2 mux_inst_35 (
  .O(doutb[17]),
  .I0(dpx9b_inst_2_doutb[17]),
  .I1(dpx9b_inst_3_doutb[17]),
  .S0(dff_q_1)
);
endmodule //Gowin_VRAM_DPB
