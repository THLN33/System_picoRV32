/*
 * ============================================================================
 * Module      : dvi_tx_clk_drv
 * Description : HDMI/DVI Differential Clock Output Buffer.
 * Converts the single-ended internal pixel clock into a differential 
 * TMDS clock pair (Positive/Negative) to synchronize the display receiver.
 *
 * ============================================================================
 * IO Description:
 * - pixel_clock : The internal global clock used for video timing.
 * - tmds_clk [1]: Positive differential output (P-side).
 * - tmds_clk [0]: Negative differential output (N-side).
 * ============================================================================
 * Hardware Primitives:
 * - ELVDS_OBUF: A Gowin-specific hardware primitive for "Emulated Low Voltage 
 * Differential Signaling" output. It ensures the signal meets the electrical 
 * swing and impedance requirements of the TMDS physical layer.
 * ============================================================================
 * Technical Notes:
 * 1. Phase Alignment: This buffer maintains the phase relationship between 
 * the clock and the high-speed data lanes generated in 'dvi_tx_top'.
 * 2. Signal Integrity: By using a dedicated hardware buffer (ELVDS), 
 * the design minimizes jitter and ensures compatibility with HDMI monitors.
 *
 * Credits: Adapted from Sipeed TangMega/Gowin HDMI examples.
 * @from : https://github.com/sipeed/TangMega-138K-example/hdmi_colorbar/eda_proj
 * ============================================================================
 */

module dvi_tx_clk_drv(
	
	input				pixel_clock,
	output	[1 : 0]		tmds_clk
);
	
	wire tmds_clk_pre;
	
	ELVDS_OBUF tmds_bufds_isnt0 (
		.I(pixel_clock),
		.O(tmds_clk[1]),
		.OB(tmds_clk[0])
	);
	
endmodule
