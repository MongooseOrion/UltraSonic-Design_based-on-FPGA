module display(
		input  				sys_clk50m,
		input  				sys_rst,
		input 		[3:0] 	A0,
		input 		[3:0] 	A1,
		input 		[3:0] 	A2,
		input 		[3:0] 	A3,
		output reg 	[6:0]	sel_duan,			//LED segment selection
		output reg 	[3:0]	sel_bit,			//LED bit selection
		output reg dp
    );


parameter AB = 'd300000;						//This time number can change freely, only if eyes can't realize the change of screen
reg[17:0] cnt;									//Dynamic scanning counter
												

always@(posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		cnt<=1'b0;
	else 
		if(cnt == (AB-1) )
			cnt<=1'b0;
		else 
			cnt<=cnt+1;
end


//
//Dynamic scanning
//
reg[3:0]digit;													//Define a register that storage display data
always@(posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst) 
		begin
			sel_bit <= 4'b0111;
			dp <= 0;
		end
	else 
		if(cnt==AB-1) 
			begin
				sel_bit <= {sel_bit[0],sel_bit[3:1]};
				dp <= 1'b1;
			end
		else 
			begin
				sel_bit <= sel_bit;
				dp <= dp;
			end
end


//
// select which LED will be lighting
//
always@(posedge sys_clk50m or negedge sys_rst)
begin
	if(!sys_rst)
		digit<=4'b1111;
	else 
		case(sel_bit)
			4'b1110:digit <= A0   		;
			4'b1101:digit <= A1   		;
			4'b1011:digit <= A2   		;
			4'b0111:digit <= A3   		;
			default:digit <= digit		;
		endcase
end


//
//LED display
//
always@(*)
begin
	case(digit)
		4'b0000:sel_duan<=7'b0000001;
		4'b0001:sel_duan<=7'b1001111;
		4'b0010:sel_duan<=7'b0010010;
		4'b0011:sel_duan<=7'b0000110;
		4'b0100:sel_duan<=7'b1001100;
		4'b0101:sel_duan<=7'b0100100;
		4'b0110:sel_duan<=7'b0100000;
		4'b0111:sel_duan<=7'b0001111;
		4'b1000:sel_duan<=7'b0000000;
		4'b1001:sel_duan<=7'b0000100;
		default sel_duan<=7'b0000001;
	endcase
end

endmodule
