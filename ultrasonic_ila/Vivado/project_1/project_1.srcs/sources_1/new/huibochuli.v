`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/09 16:33:47
// Design Name: 
// Module Name: huibochuli
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module huibochuli(
//system singnals
	input 				sys_clk50m 	,
	input 				sys_rst 	,
	//supersonic wave module singnals
	input 				Echo 		,
	
	output 	reg 		trig 		,
	//connect with Nixie tube display
	output 	reg [15:0] 	data        ,	
	
	//wave datactive
	output             cnt_17k_en_w ,           
	output    [11:0]      cnt_17k_w,
	output             clk_17k_w

    );

//
// Generate trig 
//
reg [25:0] cnt_trig;
always @ (posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		cnt_trig <= 1'b0;
	else 
		if(cnt_trig == 'd12_500_000)
			cnt_trig <= 'd0;
		else 
			cnt_trig <= cnt_trig + 1'b1;
end
always @ (posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		trig <= 1'b0;
	else 
		if(cnt_trig <= 'd500)
			trig <= 1'b1;
		else 
			trig <= 1'b0;
end 

endmodule
