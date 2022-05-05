module display(

		input				CLK_50M,
		input				RST,
		input		[15:0]	data,
		output reg	[6:0]	seg_duan,			//LED segment choose signal
		output reg	[2:0]	seg_sel				//LED bit choose signal
);

reg 				[3:0]	clk_cnt;  			//clock frequency counter
reg							dri_clk;    		//LED clock driver, 5MHz
reg					[3:0] 	scan_sel;   		//Scan select counter
reg					[3:0] 	seg_data;
reg 				[15:0] 	num;
reg 						flag;      			//Mark signal(means cnt0=1ms)
reg 				[2:0] 	cnt_sel;    		//LED bit choose counter
reg 				[12:0]  cnt0;       		//LED clock driving counter

always @ (posedge CLK_50M or negedge RST) 
begin
 if(!RST) begin
       clk_cnt <= 4'd0;
       dri_clk <= 1'b1;
   end
   else if(clk_cnt == 4) begin
       clk_cnt <= 4'd0;
       dri_clk <= ~dri_clk;
   end
   else begin
       clk_cnt <= clk_cnt + 1'b1;
       dri_clk <= dri_clk;
   end
end

always @ (  posedge dri_clk or negedge RST) 
begin
    if (!RST)
        num<= 16'd0;
    else 
	 begin
		num[15:12] <= 	data [15:12];
        num[11:8]  <=	data[11:8] ;
		num[7:4]   <=	data[7:4] ;
        num[3:0]   <= 	data [3:0];
	end
end

always @ (posedge dri_clk or negedge RST) begin
    if (RST == 1'b0) begin
        cnt0 <= 13'b0;
        flag <= 1'b0;
     end
    else if (cnt0 < 'd4999) begin
        cnt0 <= cnt0 + 1'b1;
        flag <= 1'b0;
     end
    else begin
        cnt0 <= 13'b0;
        flag <= 1'b1;
     end
end

always @ (posedge dri_clk or negedge RST) begin
    if (RST == 1'b0)
        cnt_sel <= 3'b0;
    else if(flag) begin
        if(cnt_sel < 3'd3) 							//Every LED rotates displaying(from the first to *)
            cnt_sel <= cnt_sel + 1'b1;
        else
            cnt_sel <= 3'b0;
    end
    else
        cnt_sel <= cnt_sel;
end




always@(posedge dri_clk or negedge RST)
begin
	if(!RST)
	begin
		seg_sel <= 3'b111;
		seg_data <= 4'd0;
	end
	else
	begin
		case(cnt_sel)
			//first digital led
			4'd0:
			begin
				seg_sel <= 3'b110;
				seg_data <= num[3:0];
			end
			//second digital led
			4'd1:
			begin
				seg_sel <= 3'b101;
				seg_data <= num[7:4];
			end
			//...
			4'd2:
			begin
				seg_sel <= 3'b011;
				seg_data <= num[11:8];
			end

			default:
			begin
				seg_sel <= 3'b111;
				seg_data <= 4'b0;
			end
		endcase
	end
end

	 
	 
//	 
//Seven segment display
//
always@(*)
begin
	case(seg_data)
		//Common anode structure
		'd0:seg_duan<=7'b1000000;
		'd1:seg_duan<=7'b1111001;
		'd2:seg_duan<=7'b0100100;
		'd3:seg_duan<=7'b0110000;
		'd4:seg_duan<=7'b0011001;
		'd5:seg_duan<=7'b0010010;
		'd6:seg_duan<=7'b0000010;
		'd7:seg_duan<=7'b1111000;
		'd8:seg_duan<=7'b0000000;
		'd9:seg_duan<=7'b0010000;
		default seg_duan<=7'b1100000;
	endcase	
end
endmodule


