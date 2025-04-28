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
// uart 数据输入输出模块
// 
module uart_trans(
    input               clk         ,   
    input               rst_n       ,   

    input               uart_rx     ,   
    output              uart_tx     , 
    output              send_end    ,  

    input               data_in_flag,
    input   [7:0]       data_in
);

uart_rx u_uart_rx(
    .clk                (clk            ),
    .rst                (rst_n          ),
    .uart_rx            (uart_rx        )
);

uart_tx u_uart_tx(
    .clk                (clk            ),
    .rst                (rst_n          ),
    .uart_tx            (uart_tx        ),
    .data_in            (data_in        ),
    .data_in_flag       (data_in_flag   ),
    .send_end           (send_end       )
);

endmodule