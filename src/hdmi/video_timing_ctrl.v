/*
 * ============================================================================
 * Module : video_timing_ctrl
 * Description : Video Signal Timing Generator (1080p Default).
 * Generates Horizontal (HSync) and Vertical (VSync) synchronization pulses,
 * Data Enable (DEN), and pixel coordinates (X, Y) for a video.
 *
 * ============================================================================
 * Parameters (Timing Specification):
 * - video_hlength : Total horizontal cycles (Visible + Blanking).
 * - video_vlength : Total vertical lines (Visible + Blanking).
 * - hsync_len     : Width of the Horizontal Sync pulse.
 * - hbp_len       : Horizontal Back Porch length.
 * - t_vmarge      : Optional vertical margin to crop/offset the active area.
 * ============================================================================
 * IO Description:
 * - pixel_clock      : Input clock (Matches pixel rate, e.g., 148.5MHz for 1080p).
 * - ext_sync         : Optional external trigger to synchronize the frame.
 * - pixel_x / pixel_y: Current active display coordinates (relative to 0,0).
 * - video_vsync      : Vertical synchronization output.
 * - video_hsync      : Horizontal synchronization output.
 * - video_den        : Data Enable (High during visible pixel time).
 * ============================================================================
 * Implementation Details:
 * - Counter-based: Uses internal 'h_pos' and 'v_pos' to track the scanning beam.
 * - Visibility Logic: Dynamically calculates 'h_visible' and 'v_visible' based
 * on standard Front/Back porch definitions.
 * - Vertical Margin: Includes a custom 't_vmarge' parameter to reduce the
 * active vertical window, useful for UI centering or letterboxing.
 *
 * Credits: Adapted from Sipeed TangMega/Gowin HDMI examples.
 * @from : https://github.com/sipeed/TangMega-138K-example/hdmi_colorbar/eda_proj
 * ============================================================================
 */

module video_timing_ctrl #(
		
	parameter video_hlength		= 2200,
	parameter video_h_visible	= 1920,
	parameter video_hsync_pol	= 1,
	parameter video_hsync_len	= 44,
	parameter video_hbp_len		= 148,

    parameter sync_v_pos		= 132,

	parameter video_vlength		= 1125,
	parameter video_v_visible	= 1080,
	parameter video_vsync_pol	= 1,
	parameter video_vsync_len	= 5,
	parameter video_vbp_len		= 36,

	parameter sync_h_pos		= 1079,


    parameter t_vmarge          = 0
)
(
	input				pixel_clock,
	input				reset,
	input				ext_sync,
	
	output	[13 : 0]	timing_h_pos,
	output	[13 : 0]	timing_v_pos,
	output	[13 : 0]	pixel_x,
	output	[13 : 0]	pixel_y,
	
	output				video_vsync,
	output				video_hsync,
	output				video_den,
	output				video_line_start
);
	
	localparam t_hsync_end = video_hsync_len - 1;
	localparam t_hvis_begin = video_hsync_len + video_hbp_len;
	localparam t_hvis_end = t_hvis_begin + video_h_visible - 1;
	
	localparam t_vsync_end = video_vsync_len - 1;
	localparam t_vvis_begin = video_vsync_len + video_vbp_len;
	localparam t_vvis_end = t_vvis_begin + video_v_visible - 1;
	
	localparam t_vmarge_begin = t_vvis_begin + t_vmarge;
	localparam t_vmarge_end = t_vvis_end - t_vmarge;

	reg		[13 : 0]	h_pos;
	reg		[13 : 0]	v_pos;
	
	wire	[13 : 0]	x_int;
	wire	[13 : 0]	y_int;
	
	wire				v_visible;
	wire				h_visible;
	
	wire				hsync_pos;
	wire				vsync_pos;
	
    wire        v_marge;

	reg					ext_sync_last;
	reg					ext_sync_curr;
	
	always@(posedge pixel_clock)begin
		
		if(reset)begin
			
			h_pos <= 0;
			v_pos <= 0;
			
		end else begin
			
			if(ext_sync_curr & !ext_sync_last)begin
				
				h_pos <= sync_h_pos;
				v_pos <= sync_v_pos;
				
			end else begin
				
				if(h_pos == (video_hlength-1))begin
					
					h_pos <= 0;
					
					if(v_pos == (video_vlength-1))begin
						v_pos <= 0;
					end else begin
						v_pos <= v_pos + 1'b1;
					end
					
				end else begin
					h_pos <= h_pos + 1'b1;
				end
			end
			
			ext_sync_curr <= ext_sync;
			ext_sync_last <= ext_sync_curr;
		end
	end
	
	assign v_visible = ((v_pos >= t_vvis_begin) & (v_pos <= t_vvis_end)) ? 1'b1 : 1'b0;
	assign h_visible = ((h_pos >= t_hvis_begin) & (h_pos <= t_hvis_end)) ? 1'b1 : 1'b0;

	assign v_marge = ((v_pos >= t_vmarge_begin) & (v_pos <= t_vmarge_end)) ? 1'b1 : 1'b0;

	


	assign x_int = (h_visible & v_visible) ? (h_pos - t_hvis_begin) : 0;
	//assign y_int = (v_visible) ? (v_pos - t_vvis_begin) : 0;

    assign y_int = (v_marge) ? (v_pos - t_vmarge_begin) : 0;
	
	assign video_den = (h_visible & v_visible);
	assign video_line_start = (v_visible & (h_pos == 0)) ? 1'b1 : 1'b0;
	
	assign vsync_pos = (v_pos <= t_vsync_end) ? 1'b1 : 1'b0;
	assign hsync_pos = (h_pos <= t_hsync_end) ? 1'b1 : 1'b0;
	
	assign video_vsync = (video_vsync_pol) ? vsync_pos : ~vsync_pos;
	assign video_hsync = (video_hsync_pol) ? hsync_pos : ~hsync_pos;
	
	assign timing_h_pos = h_pos;
	assign timing_v_pos = v_pos;
	assign pixel_x = x_int;
	assign pixel_y = y_int;
	
endmodule
