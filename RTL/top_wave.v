module top_ultrasonic(
	input  				clk_in1			,
	input  				sys_rst			,
	//supersonic wave module singnals
	input 				Echo 			,
	output 	 			trig 			,
	//Nixie tube display
	output 		[6:0]	sel_duan		,
	output 		[3:0]	sel_bit			,
	output 			 	dp
    );
wire [15:0] data;
wire        sys_clk50m;

measurement measurement_sys1 (
    .sys_clk50m         (sys_clk50m ), 
    .sys_rst            (sys_rst    ), 
    .Echo               (Echo       ), 
    .trig               (trig       ), 
    .data               (data       )
    );

display display_sys1 (
    .sys_clk50m         (sys_clk50m ), 
    .sys_rst            (sys_rst    ), 
    .A0                 (data[3:0]  ), 
    .A1                 (data[7:4]  ), 
    .A2                 (data[11:8] ), 
    .A3                 (data[15:12]), 
    .sel_duan           (sel_duan   ), 
    .sel_bit            (sel_bit    ), 
    .dp                 (dp         )
    );

clk_wiz_0 clock(
    .clk_in1            (clk_in1    ),
    .clk_out1           (sys_clk50m )
    );
    
endmodule