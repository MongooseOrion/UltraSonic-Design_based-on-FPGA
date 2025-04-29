<!-- =====================================================================
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
-->
# 基于 FPGA 的超声波测距系统

此系统基于 HC-SR04 超声波传感器进行距离测算，并可在数码管显示距离数据，或者可以通过 UART 传输距离数据到主机。

## 系统平台

  - ECE-BCD：ZYNQ XC7Z020（下面以 Xilinx 指代）
    - Vivado 2019.1
  - 盘古 50：PGL50H（下面以紫光指代）
    - PDS 2022.2 Lite SP1

## 功能

经过 FPGA 计算的距离信息，在 Xilinx 上可以通过 4 个数码管显示数值（**不推荐**）；而在紫光上则通过 UART 实时传输数据至电脑上（**推荐**），这种方式易于集成与后处理，因此是推荐的方法。距离单位均为厘米。

位于 `./FPGA` 文件夹内的约束文件和比特流文件可以分别用于 Xilinx 和紫光平台的开发与烧录。

## 实现

Xilinx 的方法一旦烧录，应该会立即在数码管中显示数据，无需另外的配置。

紫光的方法在烧录后，你可以运行位于 `./Python` 文件夹中的脚本，可以实时解析发回的距离数据。FPGA 内产生的 16 位距离数据按照低 8 位——高 8 位的顺序分割为两个字节通过 UART 传输。

## 性能评估

超声波测距的超时时间为 0.25 秒，UART 的波特率为 9600bps。