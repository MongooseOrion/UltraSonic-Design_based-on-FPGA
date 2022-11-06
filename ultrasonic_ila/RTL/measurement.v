module measurement(
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
//wire cnt_17k_en_w;
assign cnt_17k_en_w = cnt_17k_en;

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
//wire clk_17k_w;
//wire cnt_17k_w;
assign cnt_17k_w = cnt_17k;
assign clk_17k_w = clk_17k;

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

