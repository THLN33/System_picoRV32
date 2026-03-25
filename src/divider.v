/*
 *  Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module      : divider
 * Description : Generic Clock Frequency Divider.
 * Reduces the input clock frequency by a programmable integer factor.
 * Used for low-speed timing, such as blink effects or peripheral polling.
 *
 * ============================================================================
 * Parameters:
 * - DIVIDER_NUMBER : The division factor. 
 * The output 'clk_div' toggles every DIVIDER_NUMBER cycles.
 * Actual Frequency = Input_Freq / (2 * DIVIDER_NUMBER).
 * ============================================================================
 * IO Description:
 * - clk      : High-speed input source clock.
 * - reset    : Asynchronous reset (Active High).
 * - clk_div  : Resulting divided clock output (50% duty cycle).
 * ============================================================================
 * Implementation Details:
 * - Counter-based design: Uses a 32-bit register to support very large 
 * division ratios (e.g., converting MHz to Hz).
 * - T-Flip-Flop logic: The output state toggles only when the counter 
 * reaches the terminal value (DIVIDER_NUMBER - 1).
 * - Reset behavior: Resets both the counter and the output signal to zero.
 *
 * ============================================================================
 */

module divider #(parameter DIVIDER_NUMBER = 5)(
    input clk,
    input reset,
    output reg clk_div
    );
 
	reg [31:0] count;
		 
	always @ (posedge(clk), posedge(reset))
	begin
		if (reset)
			count <= 32'b0;
		else if (count == DIVIDER_NUMBER - 1)
			count <= 32'b0;
		else
			count <= count + 1;
	end

	always @ (posedge(clk), posedge(reset))
	begin
		if (reset)
			clk_div <= 1'b0;
		else if (count == DIVIDER_NUMBER - 1)
			clk_div <= ~clk_div;
		else
			clk_div <= clk_div;
	end
endmodule
