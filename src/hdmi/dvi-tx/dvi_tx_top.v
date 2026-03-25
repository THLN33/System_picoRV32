/*
 * ============================================================================
 * Module      : dvi_tx_top
 * Description : Top-Level DVI/HDMI Transmitter Physical Layer (PHY).
 * Orchestrates the encoding and serialization of RGB video data into 
 * TMDS (Transition-Minimized Differential Signaling) lanes.
 *
 * Architecture:
 * - Multi-Channel: Instantiates three parallel TMDS encoders (RGB) and PHYs.
 * - Serialization: Converts 10-bit parallel symbols into high-speed bitstreams.
 * - Clocking: Manages the differential HDMI clock lane.
 * ============================================================================
 * IO Description:
 * - pixel_clock    : Base frequency for video processing (e.g., 25MHz, 74.25MHz).
 * - ddr_bit_clock  : 5x Pixel Clock for Double Data Rate (DDR) serialization.
 * - den            : Data Enable signal (Video active vs. Blanking).
 * - hsync / vsync  : Horizontal and Vertical synchronization pulses.
 * - pixel_data     : 24-bit RGB input (8 bits per channel).
 * - tmds_clk       : Differential HDMI clock output.
 * - tmds_d[0:2]    : Three differential TMDS data lanes (Blue, Green, Red).
 * ============================================================================
 * Technical Highlights:
 * 1. Generate Loop: Efficiently instantiates Encoders and PHYs for all three 
 * color channels using SystemVerilog 'generate' blocks.
 * 2. Mapping: 
 * - Lane 0: Blue Channel + HSync + VSync.
 * - Lane 1: Green Channel + Control bits.
 * - Lane 2: Red Channel + Control bits.
 * 3. OSERDES Integration: Interface to 'dvi_tx_tmds_phy' which likely utilizes
 * FPGA-specific high-speed output primitives (OSERDES).
 *
 * Credits: Adapted from Sipeed TangMega/Gowin HDMI examples.
 * @from : https://github.com/sipeed/TangMega-138K-example/hdmi_colorbar/eda_proj
*/

module dvi_tx_top(
	
	input				pixel_clock,
	input				ddr_bit_clock,
	input				reset,
	
	input				den,
	input				hsync,
	input				vsync,
	input	[23 : 0]	pixel_data,
	
	output	[1 : 0]		tmds_clk,
	output	[1 : 0]		tmds_d0,
	output	[1 : 0]		tmds_d1,
	output	[1 : 0]		tmds_d2
);
	
	wire	[5 : 0]		ctrl;
	wire	[29 : 0]	tmds_enc;
	
	wire	[1 : 0]		data_out_to_pins [2 : 0];
	
	assign ctrl[0] = hsync;
	assign ctrl[1] = vsync;
	assign ctrl[5 : 2] = 4'b0000;
	
	assign tmds_d0 = data_out_to_pins[0];
	assign tmds_d1 = data_out_to_pins[1];
	assign tmds_d2 = data_out_to_pins[2];
	
	generate
		
		genvar i;
		
		for(i = 0; i < 3; i = i + 1)begin : gen_enc
			
			dvi_tx_tmds_enc dvi_tx_tmds_enc_inst(
				
				.clock		(pixel_clock),
				.reset		(reset),
				
				.den		(den),
				.data		(pixel_data[(8*i) +: 8]),
				.ctrl		(ctrl[(2*i) +: 2]),
				.tmds		(tmds_enc[(10*i) +: 10])
			);
			
			dvi_tx_tmds_phy dvi_tx_tmds_phy_inst(
				
				.pixel_clock		(pixel_clock),
				.ddr_bit_clock		(ddr_bit_clock),
				.reset				(reset),
				.data				(tmds_enc[(10*i) +: 10]),
				.tmds_lane			(data_out_to_pins[i])
			);
		end
		
	endgenerate
	
	dvi_tx_clk_drv clock_phy(
		
		.pixel_clock	(pixel_clock),
		.tmds_clk		(tmds_clk)
	);
	
endmodule
