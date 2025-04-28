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
// 激励超声波雷达，并处理回波数据，获得距离数据（以自然二进制码表示）
//
module measure_nbc #(
	parameter CLK_FREQ = 'd50_000_000			// 50MHz
)(
	input 				clk 			,
	input 				rst_n 			,

	// 超声波信号
	input 				echo 			,
	output 	reg 		trig 			,

	output 	reg [15:0] 	distance_data	,
	output 	reg 		distance_valid			// 距离数据有效标志	
);

localparam DIV_CLK_17k_CNT = CLK_FREQ / 17_000 + 1'b1;			// 17kHz	
localparam TIME_OUT = 'd12_500_000;
localparam TRIG_WIDTH_CNT = 10 * (CLK_FREQ / 10**6);			// 10us

wire 			nege_echo;
wire 			pose_echo;
wire            pose_clk_17k;

reg [2:0] 		echo_delay;
reg 			cnt_17k_en;
reg [11:0] 		cnt_17k;
reg 			clk_17k;
reg [25:0] 		cnt_trig;
reg [15:0] 		distance_data_r;

assign pose_echo = (~echo_delay[2]) & echo_delay[1];
assign nege_echo = echo_delay[2] & (!echo_delay[1]);
assign pose_clk_17k = (cnt_17k == DIV_CLK_17k_CNT / 2 - 1'b1) ? 1'b1 : 1'b0;


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		echo_delay <= 'd0;
	end
	else begin
		echo_delay <= {echo_delay[1:0],echo};
	end
end 


//
// 产生	17kHz 的时钟信号，因为声速是 340m/s，此频率利于整除计算
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt_17k_en <= 'b0;
	end
	else begin
		if(pose_echo == 1'b1) begin
			cnt_17k_en <= 1'b1;
		end
		else begin
			if(nege_echo == 1'b1) begin
				cnt_17k_en <= 1'b0;
			end
			else begin
				cnt_17k_en <= cnt_17k_en;
			end
		end
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt_17k <= 'd0;
	end
	else begin
		if(cnt_17k_en == 1'b1) begin
			if(cnt_17k == DIV_CLK_17k_CNT - 1'b1) begin
				cnt_17k <= 'd0;
			end
		    else begin
				cnt_17k <= cnt_17k + 1'b1;
			end
		end
		else begin
			cnt_17k <= 'd0;
		end
	end
end 


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		clk_17k <= 1'b0;
	end
	else begin
		if(cnt_17k < (DIV_CLK_17k_CNT / 2 - 1'b1)) begin
			clk_17k <= 1'b0;
		end
		else begin
			clk_17k <= 1'b1;
		end
	end
end


//
// 产生触发信号，激励超声波雷达
// trig 信号的宽度应大于 10us
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt_trig <= 1'b0;
	end
	else begin
		if(cnt_trig == TIME_OUT) begin
			cnt_trig <= 'd0;
		end
		else begin
			cnt_trig <= cnt_trig + 1'b1;
		end
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		trig <= 1'b0;
	end
	else begin
		if(cnt_trig <= TRIG_WIDTH_CNT + 'd10) begin
			trig <= 1'b1;
		end
		else begin
			trig <= 1'b0;
		end
	end
end 


//
// 处理回波数据，获得距离数据
// 采用 17kHz 作为计数脉冲，其周期个数在数值上等于超声波所测距离（厘米）
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		distance_data_r <= 'd0;
	end
	else begin
		if(pose_clk_17k == 1'b1) begin
			distance_data_r <= distance_data_r + 1'b1;
		end
		else begin
			if(cnt_trig == TIME_OUT) begin
				distance_data_r <= 'd0;
			end
			else begin
				distance_data_r <= distance_data_r;
			end
		end
	end
end 


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		distance_data <= 'd0;
		distance_valid <= 1'b0;
	end
	else begin
		if(cnt_trig == TIME_OUT - 1'b1) begin
			distance_data <= distance_data_r;
			distance_valid <= 1'b1;
		end
		else begin
			distance_data <= distance_data ;
			distance_valid <= 1'b0;
		end
	end
end 


endmodule

