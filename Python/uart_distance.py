''' ======================================================================
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
* FILE ENCODER TYPE: UTF-8
* ========================================================================
'''
# 使用 UART 串口通信获取距离传感器数据
#
import serial

# 循环读取并打印
ser = serial.Serial(port='COM19', baudrate=9600, timeout=1)
while True:
    data = ser.read(2)  # 读取 2 字节
    if data:
        # 调换字节顺序
        data = data[::-1]
        # 计算距离，单位为米
        distance = int.from_bytes(data, byteorder='big') / 100.0
        # 打印距离
        print(f"Distance: {distance:.2f} m")