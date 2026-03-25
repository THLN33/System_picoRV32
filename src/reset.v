/*
 * ============================================================================
 * Module      : reset_control
 * Description : Synchronous Reset Controller and Debouncer.
 * Ensures a stable system-wide reset signal by delaying the release of 
 * 'reset_n' until the clock has stabilized and a specific count is reached.
 *
 * ============================================================================
 * IO Description:
 * - clk            : Global system clock.
 * - reset_button_n : Raw external reset input (Active-Low).
 * - reset_n        : Synchronized system reset output (Active-High internally, 
 * Active-Low for the CPU).
 * ============================================================================
 * Implementation Details:
 * - Counter Logic: Uses a 6-bit counter to hold the reset state for 64 clock
 * cycles after the physical button is released or power is applied.
 * - Rising Edge Requirement: Specifically designed to satisfy the PicoRV32
 * requirement of seeing a clean rising edge on its 'resetn' port.
 * - Reduction AND Operator: The 'assign reset_n = &reset_count' ensures that
 * reset only de-asserts once every bit in the counter is logic '1'.
 *
 * Author : Grug Huhler
 * License: SPDX BSD-2-Clause
 * ============================================================================
 */

module reset_control (
        input wire  clk,
        input wire  reset_button_n,
        output wire reset_n
);
    reg [5:0] reset_count = 0;

    always @(posedge clk)
    if (reset_button_n)
        reset_count <= reset_count + !reset_n;
    else
        reset_count <= 'b0;

    // picorv32 must see a reset_n rising edge so hold it active
    // until a count completes.
    assign reset_n = &reset_count;  // 1 when all bits are set
    
endmodule
