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
// 
// 
module fpga_top_uart(
    input 				clk 	    ,
    input 				rst_n 	    ,

    // 超声波信号   
    input 				echo 	    ,
    output 		        trig 	    ,

    input               uart_rx     ,
    output              uart_tx     
);

wire [15:0]     distance_data   ;
wire            distance_valid  ;
wire [15:0]     data_tx_cache   ;
wire            data_tx_en      /*synthesis PAP_MARK_DEBUG="1"*/;

reg             data_in_flag    ;
reg [7:0]       data_in         ;
reg [1:0]       data_tx_en_cnt  ;

assign data_tx_cache = ((distance_valid == 1'b1) && (data_tx_en == 1'b0)) ? distance_data : data_tx_cache;
assign data_tx_en = data_tx_en_cnt[0] ^ data_tx_en_cnt[1];

measure_nbc measure_nbc_sys1 (
    .clk                (clk            ),
    .rst_n              (rst_n          ),
    .echo               (echo           ),
    .trig               (trig           ),
    .distance_data      (distance_data  ),
    .distance_valid     (distance_valid )
);


// 距离数据拆分为 2 字节
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_tx_en_cnt <= 'b0;
    end
    else if((distance_valid == 1'b1) && (data_tx_en_cnt == 2'd0)) begin
        data_tx_en_cnt <= 2'd1;
    end
    else if((data_tx_en_cnt == 2'd1) && (send_end == 1'b1)) begin
        data_tx_en_cnt <= 2'd2;
    end
    else if((data_tx_en_cnt == 2'd2) && (send_end == 1'b1)) begin
        data_tx_en_cnt <= 2'd0;
    end
    else begin
        data_tx_en_cnt <= data_tx_en_cnt;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_in_flag <= 'b0;
        data_in <= 'b0;
    end
    else begin
        if((distance_valid == 1'b1) && (data_tx_en == 1'b0)) begin
            data_in_flag <= 1'b1;
            data_in <= data_tx_cache[7:0];
        end
        else if((data_tx_en_cnt == 2'd1) && (send_end == 1'b1)) begin
            data_in_flag <= 1'b1;
            data_in <= data_tx_cache[15:8];
        end
        else begin
            data_in_flag <= 1'b0;
            data_in <= data_in;
        end
    end
end


uart_trans u_uart_trans(
    .clk                (clk            ),
    .rst_n              (rst_n          ),
    .uart_rx            (uart_rx        ),
    .uart_tx            (uart_tx        ),
    .send_end           (send_end       ),
    .data_in_flag       (data_in_flag   ),
    .data_in            (data_in        )
);

endmodule