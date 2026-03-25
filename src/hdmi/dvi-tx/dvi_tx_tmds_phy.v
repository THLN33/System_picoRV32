/*
 * ============================================================================
 * Module      : dvi_tx_tmds_phy
 * Description : TMDS Data Lane Physical Layer (PHY).
 * Performs high-speed 10:1 serialization of encoded video data and drives
 * the resulting bitstream onto the differential HDMI lanes.
 *
 * ============================================================================
 * IO Description:
 * - pixel_clock    : The slow-speed word clock (Parallel data rate).
 * - ddr_bit_clock  : The high-speed serial clock (FCLK). 
 * Operates at 5x the pixel clock frequency.
 * - reset          : Asynchronous reset.
 * - data [9:0]     : 10-bit encoded TMDS symbol from the encoder.
 * - tmds_lane [1:0]: Differential output pair (Positive/Negative).
 * ============================================================================
 * Hardware Primitives:
 * - OSER10       : Gowin Output Serializer (10:1 ratio). It shifts 10 bits 
 * per pixel clock cycle using the high-speed FCLK.
 * - ELVDS_OBUF   : Differential output buffer for TMDS signaling levels.
 * ============================================================================
 * Technical Notes:
 * 1. Serialization: The OSER10 uses Double Data Rate (DDR) logic on the FCLK
 * to achieve a 10:1 ratio with only a 5x clock frequency ($5 \times 2 = 10$).
 * 2. Reset Sync: The 'reset_reg' ensures the serializer is synchronized to the 
 * pixel clock domain before starting transmission.
 *
 * Credits: Adapted from Sipeed TangMega/Gowin HDMI examples.
 * @from : https://github.com/sipeed/TangMega-138K-example/hdmi_colorbar/eda_proj
 * ============================================================================
 */
module dvi_tx_tmds_phy(
	
	input				pixel_clock,
	input				ddr_bit_clock,
	input				reset,
	input	[9 : 0]		data,
	output	[1 : 0]		tmds_lane
);
	
	reg reset_reg;
	
	wire dq_tmds;
	
	always@(posedge pixel_clock)begin
		if(reset)begin
			reset_reg <= 1'b1;
		end else begin
			reset_reg <= 1'b0;
		end
	end
	
	OSER10 tmds_serdes_inst0 (
		.Q(dq_tmds),
		.D0(data[0]),
		.D1(data[1]),
		.D2(data[2]),
		.D3(data[3]),
		.D4(data[4]),
		.D5(data[5]),
		.D6(data[6]),
		.D7(data[7]),
		.D8(data[8]),
		.D9(data[9]),
		.PCLK(pixel_clock),
		.FCLK(ddr_bit_clock),
		.RESET(reset_reg)
	);
	
	ELVDS_OBUF tmds_bufds_isnt0 (
		.I(dq_tmds),
		.O(tmds_lane[1]),
		.OB(tmds_lane[0])
	);
	
endmodule
