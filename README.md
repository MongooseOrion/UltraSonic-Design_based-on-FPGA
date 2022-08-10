# 基于FPGA的超声波测距系统
这是一个非常简单的设计例子，该类别中存在一些非常优秀的工程，该项目仅作为一种展示。<br><br>
该系统使用 *Xilinx ZYNQ* 平台进行设计，采用超声波传感器 *HC-SR04* 作为外部监测设备。可将功能分为如下几个模块：
* 顶层模块
* 时钟
* 测距模块
  * 信号触发程序块
  * 回波处理程序块
  * 波形发生程序块
  * 高速计数程序块
* 显示模块
![图片alt](https://raw.githubusercontent.com/MongooseOrion/UltraSonic-Design_based-on-FPGA/main/v1.1/Picture/%E7%BB%98%E5%9B%BE4.png?token=GHSAT0AAAAAABXMLR4BSZS3YQUEFYMNTUKOYXTRPYA "程序设计基本框架")
## 时钟
本系统使用 ***50MHz*** 时钟作为系统主时钟，使用 ***17kHz*** 信号作为计数脉冲进行测距。其中，*50MHz* 时钟需使用 *Vivado* IP库中的时钟模块才能将板载晶振的频率配置为需要的频率。<br>
## 测量模块
### 信号触发子模块
