/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module : clk_producer
 * Target : Gowin GW5A-LV25 (Tang Primer 25K)
 * Description : System Clock Generation Unit (CGU).
 * Standardizes external oscillator inputs into a suite of phase-locked
 * internal clocks for CPU, Peripherals, and High-Speed Video Serialization.
 * ============================================================================
 * IO Description:
 * - Input clk27        : currently unused for this board.
 * - Input clk50        : 50 MHz External Reference (from Oscillator).
 * - Output clk24       : 24 MHz Reference.
 * - Output clk48       : 48 MHz Reference.
 * - Output clk60       : 60 MHz Reference.
 * - Output clk_hdmi    : Pixel Clock for Video Timing.
 * - Output clk_hdmi_x5 : High-Speed Bit Clock for TMDS/HDMI serialization.
 * - clk_ready    		: Global lock signal indicating all PLLs are stable.
 * ============================================================================
 * Implementation Details:
 * - Based on Gowin_PLL Primitive (Hardware-specific PLL).
 * - Fixed Ratios: Generates multiple synchronized frequencies from a single
 * VCO (Voltage Controlled Oscillator) to maintain phase alignment.
 * - Integration: Used as the source for 'main_system' and 'video_text' modules.
 * ============================================================================
 */

module clk_producer (
        input   clk27,
        input   clk50,

        output  clk24,
        output  clk48,
        output  clk60,

        output  clk_hdmi_x5,
        output  clk_hdmi,
    
        output  clk_ready
    );

wire hdmi_pll_lock, pll0_lock, pll1_lock;

    // tp25k source 50MHz
	Gowin_PLL pll0 (
        .clkin(clk50), 
        .lock(clk_ready), 
        .clkout_60(clk60), 
        .clkout_600(clk_hdmi_x5), 
        .clkout_120(clk_hdmi), 
        .clkout_48(clk48),
        .clkout_24(clk24)
    );

endmodule