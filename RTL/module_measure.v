module measurement(

input				CLK_50M,
input 				RST,
input 				Echo,
output reg 			Trig,
output  	[15:0] 	data

);

//
// Trig
//
reg [23:0] cnt_trig;
always @ (posedge CLK_50M or negedge RST)
begin
	if(!RST)
		cnt_trig<=1'b0;
	else
		if(cnt_trig =='d500) begin					//Vh time duration		
			Trig<=0;
			cnt_trig<=cnt_trig+1'b1;
			end
		else 
			begin
				if(cnt_trig=='d1_000_000)			//Vl time duration, plus vh time is a period
					begin
						Trig<=1;
						cnt_trig<=0;
					end				
				else
					cnt_trig<=cnt_trig+1'b1;
			end
end


//
// measure the rise edge and the fall edge
//
reg Echo_2, Echo_1, cnt_en,flag;
wire pose_Echo, nege_Echo;
assign pose_Echo =(~Echo_2)&&Echo_1;				//This is the method of how to describe the rise and fall edge
assign nege_Echo = Echo_2&&(~Echo_1);
parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10; 
reg	[1:0] 	curr_state;
reg [15:0] 	cnt;
reg [15:0] 	dis_reg;
reg [15:0] 	cnt_17k;
always @ (posedge CLK_50M or negedge RST)
begin
	if(!RST)
		begin
			Echo_1 <= 1'b0;
			Echo_2 <= 1'b0;
			cnt_17k <=1'b0;
			dis_reg <=1'b0;
			curr_state <= S0;
		end
	else	
		begin
			Echo_1<=Echo;
			Echo_2<=Echo_1;
			case(curr_state)
			S0:begin
					if (pose_Echo)
						curr_state <= S1;
					else
						begin
							cnt <= 1'b0;
						end
				end
			S1:begin
					if(nege_Echo)
						curr_state <= S2;
					else
						begin
							if(cnt_17k <16'd2940)	//Because of decimal number, only can near approximately 17kHz counting
							begin
								cnt_17k <= cnt_17k + 1'b1;
							end
							else
							begin					//Once "Judgement statements" >= 1’d0, it will carry a bit. If you don't care computing resource, 
													//cnt++ command is OK too.
								cnt_17k <= 1'b0;
								cnt[3:0] <= cnt[3:0] +1'b1;
							end
								if(cnt[3:0] >= 'd10)
								begin
									cnt [3:0] <=1'b0;
									cnt [7:4]<=cnt[7:4]+1'b1;
								end
								if (cnt[7:4] >= 'd10)
								begin
									cnt[7:4]<=1'b0;
									cnt[11:8]<=cnt[11:8]+1'b1;
								end
								if (cnt[11:8]>='d10)
								begin
									cnt[11:8]<=1'b0;
									cnt[15:12]<=cnt[15:12]+1'b1;
								end
								
								if(cnt[15:12]>='d10)
								begin
									cnt[15:12]<=1'b0;
								end					
						end				
				end
			S2:begin
				dis_reg<=cnt;
				cnt <=1'b0;
				curr_state <= S0;
				end
			endcase	
		end
end

assign data = dis_reg ; 							//Assign values to the output port. Because we choose 17kHz as base clock frequency, 
													//formular is 340*T/2=170*(1/17000)*100=T(cm)
endmodule

