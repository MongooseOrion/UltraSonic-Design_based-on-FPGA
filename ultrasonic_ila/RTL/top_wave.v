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
//wire        clk_out2;

wire cnt_17k_en_w;
wire [11:0] cnt_17k_w;
wire clk_17k_w;

measurement measurement_sys1 (
    .sys_clk50m         (sys_clk50m ), 
    .sys_rst            (sys_rst    ), 
    .Echo               (Echo       ), 
    .trig               (trig       ), 
    .data               (data       ),
    .cnt_17k_en_w       (cnt_17k_en_w),
    .cnt_17k_w          (cnt_17k_w),
    .clk_17k_w            (clk_17k_w)
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
    .clk_out1           (sys_clk50m)
    //.clk_out2           (clk_out2)
);

ila_0 measurement(
    .clk                (sys_clk50m ),
    .probe0             (trig       ),
    .probe1             (data       ),
    .probe2             (cnt_17k_en_w),
    .probe3             (cnt_17k_w),
    .probe4             (clk_17k_w)
);
endmodule