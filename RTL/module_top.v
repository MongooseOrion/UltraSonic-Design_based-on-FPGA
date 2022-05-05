module top_Ranging(

input			clk_in1,
input 			RST,

//UltraSonic sensor
input wire 		Echo,
output			Trig,

//LED display (if necessary)
output [6:0] 	seg_duan,
output [2:0] 	seg_sel

//OLED IO display (if necessary)


);

wire  [15:0] data;
wire         CLK_50M;

measurement U1(
		.CLK_50M		(CLK_50M),
		.RST 			(RST),
		.Echo 			(Echo),
		.Trig 			(Trig) ,
		.data			(data)
);

display U2(
		.CLK_50M		(CLK_50M),
		.RST 			(RST),
		.data			(data),
		.seg_duan 		(seg_duan),
		.seg_sel 		(seg_sel)

);

clk_wiz_0 pll_freq(
        .clk_in1        (clk_in1),
        .clk_out1       (CLK_50M),
        .reset          (RST)         
);

endmodule
