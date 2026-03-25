/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module : clk_producer
 * Target : Gowin GW2AR-LV18 (Tang Nano 20K)
 * Description : System Clock Generation Unit (CGU).
 * Standardizes external oscillator inputs into a suite of phase-locked
 * internal clocks for CPU, Peripherals, and High-Speed Video Serialization.
 * ============================================================================
 * IO Description:
 * - Input clk27        : 27 MHz External Reference (from Oscillator).
 * - Input clk50        : currently unused for this board.
 * - Output clk24       : 24 MHz Reference.
 * - Output clk48       : 48 MHz Reference.
 * - Output clk60       : unused.
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
 
module clk_producer #(
        parameter   HDMI_M= 62,
        parameter   HDMI_N = 2
    ) (
        input   clk27,
        input   clk50,

        output  clk_hdmi_x5,
        output  clk_hdmi,

        output  clk48,

        output  clk60,

        output  clk24,

        output  clk_ready
    );

wire pll_hdmi_lock, pll0_lock, pll1_lock;


// tn20k source 27MHz
/* 
 * Primitive: Gowin_rPLL
 * This primitive uses a Gowin_rPLL to generate the high-frequency differential signaling clock.
 * By using parameters HDMI_M and HDMI_N, the module remains flexible for different video resolutions.
 */
Gowin_rPLL #(
        .IDIV(3),
        .M(HDMI_M),
        .ODIV(HDMI_N)
    ) hdmi_pll_inst0 (
        .clkout(clk_hdmi_x5), 
        .clkoutd(),
        .lock(pll_hdmi_lock),
        .clkin(clk27)
    );

/*
 * Primitive: Gowin_CLKDIV
 * This primitive is utilized as a synchronous frequency divider to derive the base
 * Pixel Clock (clk_hdmi) from the high-speed TMDS Serialization Clock (clk_hdmi_x5).
 */
Gowin_CLKDIV div5_inst0 (
        .clkout(clk_hdmi), 
        .hclkin(clk_hdmi_x5),
        .resetn(pll_hdmi_lock)
    );


/* 
 * Primitive: Gowin_rPLL
 * Input Reference (clk27):	    27 MHz 
 * Primary Output (clk48): 		48 MHz 
 * Secondary Output (clk24):	24 MHz (Internal division)
 */
Gowin_rPLL #(
        .IDIV(8),
        .M(15),
        .ODIV(16)
    ) usb_pll_inst0 (
        .clkout(clk48), 
        .clkoutd(clk24),
        .lock(pll_48_lock),
        .clkin(clk27)
    );


assign clk_ready = pll_hdmi_lock & pll_48_lock;



endmodule