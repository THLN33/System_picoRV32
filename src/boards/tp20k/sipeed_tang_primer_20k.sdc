create_clock -name clk27 -period 37.037 [get_ports {clk27}]

create_clock -name clk24 -period 41.667 [get_nets {clk24}]
create_clock -name clk48 -period 20.833 [get_nets {clk48}]
create_clock -name clk -period 16.50 [get_nets {clk}]

//create_clock -name clk_hdmi_x5 -period 8.333 [get_nets {clk_hdmi_x5}]
