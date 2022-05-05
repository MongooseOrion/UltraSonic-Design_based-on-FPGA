module top(
	
	input clk_in1,
	output trig, 
	input echo,
	 
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3
	//output [6:0] HEX4,
	//output [6:0] HEX5
);
  
  wire [32:0] distance;
  wire        clk50;
  wire        clk10;

  sonic sc (
    clk50,
	 trig,
	 echo,
	 distance
  );
   
  shownumber sn (
    clk10,
	 HEX0, HEX1, HEX2, HEX3, //HEX4, HEX5,
	 distance
  );
  
  clk_wiz_0 clock (
    .clk_in1     (clk_in1),
    .clk_out1    (clk50),
    .clk_out2    (clk10)
  );
    
endmodule