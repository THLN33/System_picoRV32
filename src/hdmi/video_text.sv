/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module : video_text.sv
 * Description : Memory-Mapped Character-Based Video Display Controller.
 * Generates real-time HDMI timing signals and renders text from a 
 * Dual-Port RAM character buffer and a Pattern ROM (Font).
 *
 * ============================================================================
 * Bus Protocol: PicoRV32 Native Bus Interface (rv32_req_t / rv32_resp_t).
 * Memory Mapping: Accessed as a contiguous block of VRAM.
 * ============================================================================
 * * Features:
 * - Dual-Clock Architecture: Bus-side (bus_clk) and Video-side (pixel_clock).
 * - Character grid rendering with configurable foreground/background colors.
 * - Hardware support for attributes: Blink, Underline, and Invert.
 * - Integrated Video Timing Controller (VTC) for HDMI-compliant sync signals.
 * ============================================================================
 * Parameters:
 * - t_vmarge/t_hmarge : Configurable border/margin sizes.
 * - border_color      : 24-bit RGB color for the non-active margin area.
 * ============================================================================
 * Technical Notes:
 * 1. Character Buffer: Utilizes Gowin Dual-Port Block RAM (DPB). 
 * - Port A: CPU Bus access (32-bit mapped, 18-bit data storage).
 * - Port B: Video pipeline read access (asynchronous to CPU).
 * 2. Font Engine: Uses Gowin pROM to store 16x24 pixel character patterns.
 * 3. Latency: The pipeline includes pixel-clock synchronized latches for 
 * character data and attributes to ensure stable rendering.
 * 4. CDC: Dual-port RAM handles the data transfer between bus_clk and pixel_clock.
 * ============================================================================
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */
import picorv32_bus_pkg::*;


module video_text #(
    	// @see https://tomverbeure.github.io/video_timings_calculator?

        parameter t_vmarge          = `VIDEO_V_MARGE,
        parameter t_v_marge_begin   = `VIDEO_V_SYNC_LEN+`VIDEO_V_BP_LEN+t_vmarge,
        parameter t_v_marge_end     = t_v_marge_begin+(`SCREEN_DY*24)-1,

        parameter t_hmarge          = `VIDEO_H_MARGE+2,    
        parameter t_h_marge_begin   = `VIDEO_H_SYNC_LEN+`VIDEO_H_BP_LEN+t_hmarge,
        parameter t_h_marge_end     = t_h_marge_begin+(`SCREEN_DX*16)-2,

        parameter border_color      = 24'h202020

) (
    	input				reset,

        input               clk24,
        input               bus_clk,

        input  rv32_req_t  req,     // Entrée : (Master -> Slave)
        output rv32_resp_t resp,    // Sortie : (Slave -> Master)

        input				pixel_clock,
	
        output				video_vsync,
        output				video_hsync,
        output				video_den,
        output				video_line_start,
        output [23:0]	    video_pixel
    );

    wire write;
    assign write = &req.wstrb; // all wstrb[3:0] == 1

    reg ready;

    always @(posedge bus_clk) begin 
        if (req.select)
            ready <= 1'b1;
        else
            ready <= 1'b0;
    end
    assign resp.ready = ready;


    wire [13:0] timing_h_pos;
    wire [13:0] timing_v_pos;
	wire [13:0]	pixel_x;
	wire [13:0]	pixel_y;

    reg [13:0] addr_memchar;  

    wire [3:0] c_text;
    wire [3:0] c_bgnd;
    wire [2:0] c_mode;
    wire [6:0] char;                             
        
    wire [17:0] char_options;

    wire [23:0] color_text;
    wire [23:0] color_bgnd;

    assign c_text = char_options[17:14];
    assign c_bgnd = char_options[13:10];
    assign c_mode = char_options[9:7];
    assign char = char_options[6:0];

    wire [4:0] pixel_char_y;
    assign pixel_char_y = pixel_y % 24;

    reg [12:0] addr_pattern_latched;
    reg [3:0] c_text_latched;
    reg [3:0] c_bgnd_latched;
    reg [2:0] c_mode_latched;

    wire [12:0] addr_pattern;                 

    assign addr_pattern = addr_pattern_latched + pixel_char_y;

    wire [15:0] pattern_data_out;
    reg [15:0] shift_reg;
    reg [23:0] out_video_pixel;
    

    wire h_marge;
    assign h_marge = ((timing_h_pos < t_h_marge_begin) | (timing_h_pos > t_h_marge_end)) ? 1'b1 : 1'b0;

    wire v_marge;
    assign v_marge = ((timing_v_pos < t_v_marge_begin) | (timing_v_pos > t_v_marge_end)) ? 1'b1 : 1'b0;


    always @(posedge pixel_clock) begin
        if (reset) 
            out_video_pixel<=0;
        else begin
            //if (video_den) begin
                if (pixel_x[3:0]==8+1) begin
                    c_text_latched = c_text;
                    c_bgnd_latched = c_bgnd;
                    c_mode_latched = c_mode;
                end
                if (pixel_x[3:0]==8+0) begin
                    shift_reg <= 16'b0000_0000_0000_0001;
                    addr_memchar <= `SCREEN_DX * (pixel_y / 24) + (timing_h_pos[13:4] - `H_CHAR_OFFSET);    // timing_h_pos / 16
                    addr_pattern_latched = {char[6:0], 3'b0} + {char[6:0], 4'b0};                           // char x 24
                   
                end else begin
                    shift_reg <= {shift_reg[0], shift_reg[15:1]};
                end
                if (h_marge | v_marge) begin
                    out_video_pixel<= border_color;
                end else begin
                    if ((shift_reg & pattern_data_out2) == 0) begin
                        out_video_pixel<=color_bgnd;
                    end else begin
                        out_video_pixel<=color_text;
                    end
                end 
                
            //end else begin
            //    out_video_pixel<=border_color; //24'hF00000;
            //end
        end
    end
    assign video_pixel = out_video_pixel;



    wire clk_lf;

	divider #(.DIVIDER_NUMBER(6_000_000)) divider_lf_inst0 (
		.clk(clk24),  // 24 MHz
		.reset(reset),
		.clk_div(clk_lf)
    );


reg clk_lf2;

always @(posedge clk_lf) begin
    clk_lf2 <= ~clk_lf2;
end 

wire underline_pos;
assign underline_pos = (pixel_char_y == 20) | (pixel_char_y == 21)| (pixel_char_y == 22);

wire f_blink;
wire underline_cond;
wire [15:0] pattern_data_out2;
wire inv_mode;




`ifdef _TWO_SPEED
assign f_blink = ( c_mode_latched[0] ) ? clk_lf : clk_lf2;
assign underline_cond = ( underline_pos ) & c_c_mode_latched[1];
assign pattern_data_out2 = underline_cond ? 16'hFFFF : pattern_data_out;
assign inv_mode =  (f_blink & c_mode_latched[2]) ^ c_mode_latched[0];
`else
assign f_blink = clk_lf2;
assign underline_cond = (~c_mode_latched[2] & c_mode_latched[1]) + 
                        (c_mode_latched[2] & c_mode_latched[1] & ~c_mode_latched[0]) +
                        (f_blink & c_mode_latched[2] & ~c_mode_latched[1] & c_mode_latched[0]) +
                        (f_blink & &c_mode_latched);
assign pattern_data_out2 = (underline_pos & underline_cond) ? 16'hFFFF : pattern_data_out;
assign inv_mode =   (f_blink & c_mode_latched[2] & ~c_mode_latched[0]) + 
                    (~c_mode_latched[2] & c_mode_latched[0]) + 
                    (&c_mode_latched);
`endif





text_color(
        .c_text(c_text_latched),
        .c_bgnd(c_bgnd_latched),
        .inv_mode(inv_mode),

        .color_text(color_text), 
        .color_bgnd(color_bgnd) 
    );



wire [17:0] data_18_out;

assign resp.rdata = {
        4'b0, data_18_out[17:14], 
        4'b0, data_18_out[13:10], 
        5'b0, data_18_out[9:7],
        1'b0, data_18_out[6:0]
    }; 




Gowin_VRAM_DPB char_buffer(
        .reseta(reset),                 //input reset picorv32 side
        .resetb(reset),                 //input reset hdmi side

        .clka(bus_clk),                 //input bus_clk
        .clkb(pixel_clock),             //input pixel_clock

        .ocea(1'b1),                    //input always enable
        .oceb(1'b1),                    //input always enable

        .cea(req.select),               //input chip select
        .ceb(1'b1),                     //input always enable

        .wrea(write),                   //input only 32 bit word at the same time 
        .wreb(1'b0),                    //input always disable, read only memory

        .ada(req.addr[15-1:2]),         //input video memory address bus (32bits access)
        .adb(addr_memchar),             //input addr_memchar

        .dina( {req.wdata[27:24], req.wdata[19:16], req.wdata[10:8], req.wdata[6:0]} ),
        .dinb(8'b0),                    // input not used because read only memory

        .douta( data_18_out ),          // readback to picorv32 bus
        .doutb( char_options )          // output char, c_mode, c_bgnd, c_text
    );


Gowin_pattern_pROM pattern_rom_inst (
        .clk(pixel_clock),                  //input clk
        .reset(reset),                      //input reset

        .oce(1'b1),                         //input always enable
        .ce(1'b1),                          //input always enable

        .ad(addr_pattern),                  //input [13-1:0] ad

        .dout(pattern_data_out)             //output [15:0] dout
    );

video_timing_ctrl #(
		
		.video_hlength(`VIDEO_H_LENGTH),
		.video_vlength(`VIDEO_V_LENGTH),
		
		.video_hsync_pol(`VIDEO_H_SYNC_POL),
		.video_hsync_len(`VIDEO_H_SYNC_LEN),
		.video_hbp_len(`VIDEO_H_BP_LEN),
		.video_h_visible(`VIDEO_H_VISIBLE),
		
		.video_vsync_pol(`VIDEO_V_SYNC_POL),
		.video_vsync_len(`VIDEO_V_SYNC_LEN),
		.video_vbp_len(`VIDEO_V_BP_LEN),
		.video_v_visible(`VIDEO_V_VISIBLE),

        .t_vmarge(t_vmarge)
		
	) video_timing_ctrl_inst0(
		
		.pixel_clock		(pixel_clock),
		.reset				(reset),
		.ext_sync			(1'b0),
		
		.timing_h_pos		(timing_h_pos),
		.timing_v_pos		(timing_v_pos),
		.pixel_x			(pixel_x),
		.pixel_y			(pixel_y),
		
		.video_vsync		(video_vsync),
		.video_hsync		(video_hsync),
		.video_den			(video_den),
		.video_line_start	(video_line_start)
	);

endmodule
