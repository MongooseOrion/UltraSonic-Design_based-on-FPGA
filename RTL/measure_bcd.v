/* =======================================================================
* Copyright (c) 2023, MongooseOrion.
* All rights reserved.
*
* The following code snippet may contain portions that are derived from
* OPEN-SOURCE communities, and these portions will be licensed with: 
*
* <NULL>
*
* If there is no OPEN-SOURCE licenses are listed, it indicates none of
* content in this Code document is sourced from OPEN-SOURCE communities. 
*
* In this case, the document is protected by copyright, and any use of
* all or part of its content by individuals, organizations, or companies
* without authorization is prohibited, unless the project repository
* associated with this document has added relevant OPEN-SOURCE licenses
* by github.com/MongooseOrion. 
*
* Please make sure using the content of this document in accordance with 
* the respective OPEN-SOURCE licenses. 
* 
* THIS CODE IS PROVIDED BY https://github.com/MongooseOrion. 
* FILE ENCODER TYPE: GBK
* ========================================================================
*/
// 激励超声波雷达，并处理回波数据，获得距离数据（以 8421BCD 码表示）
//
module measure_bcd(
	//system singnals
	input 				sys_clk50m 	,
	input 				sys_rst 	,
	//supersonic wave module singnals
	input 				Echo 		,
	output 	reg 		trig 		,
	//connect with Nixie tube display
	output 	reg [15:0] 	data 	
    );


//
// generate cnt_17k_en
// Singal bit cross clock domain processing, delay 2 clock period
reg [2:0] Echo_delay;
always @ (posedge sys_clk50m or negedge sys_rst)
begin
if(!sys_rst)
	begin
		Echo_delay <= 'd0;
	end
else 
	begin
		Echo_delay <= {Echo_delay[1:0],Echo};
	end
end 


//
// Detect the rising and falling edge
//
wire nege_Echo;
wire pose_Echo;
assign pose_Echo = (~Echo_delay[2])&&Echo_delay[1];
assign nege_Echo = Echo_delay[2]&&(!Echo_delay[1]);


//
// Generate counting valid signal
//
reg cnt_17k_en;
always @ (posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		cnt_17k_en <= 'd0;
	else 
		if(pose_Echo)
			cnt_17k_en <= 1'b1;
		else 
			if(nege_Echo)
				cnt_17k_en <= 1'b0;
			else 
				cnt_17k_en <= cnt_17k_en;
end


//
// div_clk_17khz
//
reg [11:0] cnt_17k;
always @ (posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		cnt_17k <= 'd0;
	else 
		if(cnt_17k_en)
			begin
				if(cnt_17k == 'd2942)
					cnt_17k <= 'd0;
		        else 
		        	cnt_17k <= cnt_17k + 1'b1;
			end
		else 
			cnt_17k <= 'd0;
end 
reg clk_17k;
always @ (posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		clk_17k <= 1'b0;
	else 
		if(cnt_17k == 'd2942)
			clk_17k <= 1'b1;
		else 
			clk_17k <= 1'b0;
end


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


//
// Display part, with counting by wave counter(17kHz)
//
reg [15:0] data_r;
always @ (posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		data_r <= 'd0;
	else 
		if(clk_17k == 1'b1)
			begin
				if(data_r[3 :0 ] == 'd9)
					begin
						data_r[7 :4 ] <= 1'b1 + data_r[7 :4 ];
						data_r[3 :0 ] <= 'd0;
					end 
				else 
					if(data_r[7 :4 ] == 'd9)
						begin
							data_r[11:8 ] <= 1'b1 + data_r[11:8 ];
							data_r[7 :4 ] <= 'd0;
						end 
					else 
						if(data_r[11:8 ] == 'd9)
							begin
								data_r[15:12] <= 1'b1 + data_r[15:12];
								data_r[11:8 ] <= 'd0;
							end 
						else 
							data_r <= data_r + 1'b1;
			end 
		else 
			if(cnt_trig == 'd12_500_000)
				data_r <= 'd0;
			else
				data_r <= data_r;
end 


//
// Solve problem that the data will be reset
//
always @ (posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		data <= 'd0;
	else 
		if(cnt_trig == 'd12_499_999)
			data <= data_r;
		else 
			data <= data ;
end 


endmodule

