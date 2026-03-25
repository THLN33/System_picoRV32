/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module : text_color.sv
 * Description : 4-bit to 24-bit RGB Color Palette (Look-Up Table).
 * Maps character color indices to standard 24-bit RGB values and handles
 * the inversion logic for text attributes (Invert/Flash).
 *
 * ============================================================================
 * IO Description:
 * - c_text   [3:0] : Index for the foreground (text) color.
 * - c_bgnd   [3:0] : Index for the background color.
 * - inv_mode       : Control signal to swap foreground and background.
 * (Used for blinking or highlighted text).
 * - color_text [23:0]: Resulting 24-bit RGB foreground color.
 * - color_bgnd [23:0]: Resulting 24-bit RGB background color.
 * ============================================================================
 * Color Palette Mapping (Standard VGA/ANSI 16-color palette):
 * 0: BLACK   | 1: MAROON | 2: GREEN   | 3: OLIVE
 * 4: NAVY    | 5: PURPLE | 6: TEAL    | 7: SILVER
 * 8: GRAY    | 9: RED    | A: LIME    | B: YELLOW
 * C: BLUE    | D: FUCHSIA| E: AQUA    | F: WHITE
 * ============================================================================
 * Implementation Details:
 * - Purely combinational logic (zero clock latency).
 * - Utilizes a Verilog function 'get_color' for clean mapping.
 * - Hardware efficient: The 'inv_mode' multiplexing happens at the 
 * output to minimize logic duplication.
 *
 * ============================================================================
 */

module text_color(
        input wire [3:0]    c_text,
        input wire [3:0]    c_bgnd,
        input wire          inv_mode,

        output wire [23:0]  color_text, 
        output wire [23:0]  color_bgnd 
    );


    localparam BLACK 	= 24'h000000;
    localparam MAROON 	= 24'h800000;
    localparam GREEN 	= 24'h008000;
    localparam OLIVE 	= 24'h808000;
    localparam NAVY 	= 24'h000080;
    localparam PURPLE 	= 24'h800080;
    localparam TEAL 	= 24'h008080;
    localparam SILVER 	= 24'hC0C0C0;
    localparam GRAY 	= 24'h808080;
    localparam RED 	    = 24'hFF0000;
    localparam LIME 	= 24'h00FF00;
    localparam YELLOW 	= 24'hFFFF00;
    localparam BLUE 	= 24'h0000FF;
    localparam FUCHSIA  = 24'hFF00FF;
    localparam AQUA 	= 24'h00FFFF;
    localparam WHITE 	= 24'hFFFFFF;

    localparam COLOR_BLACK      = 0;
    localparam COLOR_MAROON 	= 1;
    localparam COLOR_GREEN 	    = 2;
    localparam COLOR_OLIVE 	    = 3;
    localparam COLOR_NAVY 		= 4;
    localparam COLOR_PURPLE 	= 5;
    localparam COLOR_TEAL 		= 6;
    localparam COLOR_SILVER 	= 7;
    localparam COLOR_GRAY 		= 8;
    localparam COLOR_RED 		= 9;
    localparam COLOR_LIME 		= 10;
    localparam COLOR_YELLOW 	= 11;
    localparam COLOR_BLUE 		= 12;
    localparam COLOR_FUCHSIA 	= 13;
    localparam COLOR_AQUA 		= 14;
    localparam COLOR_WHITE 	    = 15;


    function [23:0] get_color (input [3:0] color_index);
		begin
        get_color =
                (color_index==COLOR_BLACK) ? BLACK :
                (color_index==COLOR_MAROON) ? MAROON :
                (color_index==COLOR_GREEN) ? GREEN :
                (color_index==COLOR_OLIVE) ? OLIVE :
                (color_index==COLOR_NAVY) ? NAVY :
                (color_index==COLOR_PURPLE) ? PURPLE :
                (color_index==COLOR_TEAL) ? TEAL :
                (color_index==COLOR_SILVER) ? SILVER :
                (color_index==COLOR_GRAY) ? GRAY :
                (color_index==COLOR_RED) ? RED :
                (color_index==COLOR_LIME) ? LIME :
                (color_index==COLOR_YELLOW) ? YELLOW :
                (color_index==COLOR_BLUE) ? BLUE :
                (color_index==COLOR_FUCHSIA) ? FUCHSIA :
                (color_index==COLOR_AQUA) ? AQUA :
                WHITE;
		end
	endfunction

    assign color_text = (inv_mode) ? get_color(c_bgnd) : get_color(c_text);
    assign color_bgnd = (inv_mode) ? get_color(c_text) : get_color(c_bgnd);

endmodule
