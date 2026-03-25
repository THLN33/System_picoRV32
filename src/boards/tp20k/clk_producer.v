/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module : clk_producer
 * Target : Gowin GW2A-LV18 (Tang Primer 20K)
 * Description : System Clock Generation Unit (CGU).
 * Standardizes external oscillator inputs into a suite of phase-locked
 * internal clocks for CPU, Peripherals, and High-Speed Video Serialization.
 * ============================================================================
 * IO Description:
 * - Input clk27        : 27 MHz External Reference (from Oscillator).
 * - Input clk50        : currently unused for this board.
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


module clk_producer #(
        // default timings for HDMI 1366x768: 425.25
        parameter   HDMI_IDIV = 3,
        parameter   HDMI_M= 62,
        parameter   HDMI_N = 2
    ) (
        input   clk27,
        input   clk50,

        output  clk_hdmi_x5,
        output  clk_hdmi,

        output  clk60,
        output  clk48,
        output  clk24,
    
        output  clk_ready
    );

wire hdmi_pll_lock, pll0_lock, pll1_lock;


/* 
 * Primitive: Gowin_rPLL
 * This primitive uses a Gowin_rPLL to provide 60MHz output
 */
Gowin_rPLL #(
        .IDIV(8),
        .M(19),
        .ODIV(16)
    ) main_pll_inst0 (
        .clkout(clk60), 
        .clkoutd(),
        .lock(pll0_lock),
        .clkin(clk27)
    );

/* 
 * Primitive: Gowin_rPLL
 * This primitive uses a Gowin_rPLL to generate the high-frequency differential signaling clock.
 * By using parameters HDMI_IDIV, HDMI_M and HDMI_N, the module remains flexible for different video resolutions.
 */
Gowin_rPLL #(
        .IDIV(HDMI_IDIV),
        .M(HDMI_M),
        .ODIV(HDMI_N)
    ) hdmi_pll_inst0 (
        .clkout(clk_hdmi_x5), 
        .clkoutd(),
        .lock(hdmi_pll_lock),
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
        .resetn(hdmi_pll_lock)
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
        .lock(pll1_lock),
        .clkin(clk27)
    );


assign clk_ready = pll0_lock & pll1_lock & hdmi_pll_lock;



endmodule