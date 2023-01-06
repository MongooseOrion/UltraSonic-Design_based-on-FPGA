[*Click here to tranlate in English*](https://github.com/MongooseOrion/UltraSonic-Design_based-on-FPGA/blob/main/README_EN.md)
# 基于FPGA的超声波测距系统
超声波测距系统是一种比较可靠的非接触式测距系统，它在近距离的场景非常有性能和成本的优势。下面来介绍一下设计。<br><br>
**开发平台**：*Windows11 21H2*, *Vivado 2018.2*

## 超声波测距原理
一般可采用集成式超声波的传感器 HC-SR04 来进行设计，它在外部有输入信号 **TRIG** 和输出信号 **ECHO**，而在内部有输出脉冲 **TX** 和输入脉冲 **RX** 两个信号。（名称可能有所不同，原理是相同的）

当 **TRIG** 拉高至少 10μs 后，器件可以启动。**TX** 将产生 8 个 40kHz 的脉冲用于发射超声波，同时在最后一个脉冲的下降沿拉起 **ECHO** 信号，用于记录超声波渡越时间。在反射超声波传入 **RX** 后，应该会拉起 8 个 40kHz 的脉冲信号，在最后一个脉冲的下降沿将 **ECHO** 信号拉低。显然，**ECHO** 信号的高电平时间就是超声波的渡越时间。

## 设计组成
该系统使用 *Xilinx ZYNQ* 平台进行设计，采用超声波传感器 *HC-SR04* 作为外部监测设备。可将功能分为如下几个模块：
* 顶层模块
* 时钟
* 测距模块
  * 信号触发程序块
  * 回波处理程序块
  * 波形发生程序块
  * 高速计数程序块
* 显示模块<br><br>
<img src="https://github.com/MongooseOrion/UltraSonic-Design_based-on-FPGA/blob/main/Picture/%E7%BB%98%E5%9B%BE4.png" width = '200' alt="图片alt" title="程序设计基本框架" /><br>
## 时钟
本系统使用 ***50MHz*** 时钟作为系统主时钟，使用 ***17kHz*** 信号作为计数脉冲进行测距。其中，*50MHz* 时钟需使用 *Vivado* IP库中的时钟模块才能将板载晶振的频率配置为需要的频率。<br>
## 测量模块
### 信号触发子模块
触发信号 *Trig* 需有 10μs 的上沿脉冲宽度才能使 HC-SR04 传感器工作。全局系统时钟为 ***50MHz***，周期为 0.02μs，则 **10μs** 的时间就对应为 *500* 个时钟单位。<br><br>
<img src="https://github.com/MongooseOrion/UltraSonic-Design_based-on-FPGA/blob/main/Picture/%E7%BB%98%E5%9B%BE7.png" width = '300' alt="图片alt" title="信号触发子模块程序设计框图" /> 
<img src="https://github.com/MongooseOrion/UltraSonic-Design_based-on-FPGA/blob/main/Picture/%E7%BB%98%E5%9B%BE6.png" width = '395' alt="图片alt" title="回波处理子模块程序设计框图" /><br>
### 回波处理子模块
该子程序将用于生成 ***17kHz*** 计数脉冲的使能信号。由于回响信号 *Echo* 的高电平持续时间就是超声波从发射到返回的持续时间，故测量距离则只需确定单个高电平波形的上升沿和下降沿之间的时间宽度即可。
### 波形发生子模块
主时钟 ***50MHz*** 不能被计数脉冲 *17kHz* 整除，所以取整对应约为 **2942** 个时钟单位（50% 占空比），通过定义寄存器计数 **2942** 次清零就可以实现 *17kHz* 分频。<br><br>
<img src="https://github.com/MongooseOrion/UltraSonic-Design_based-on-FPGA/blob/main/Picture/%E7%BB%98%E5%9B%BE5.png" width = '300' alt="图片alt" title="波形发生子模块程序设计框图" /> 
<img src="https://github.com/MongooseOrion/UltraSonic-Design_based-on-FPGA/blob/main/Picture/%E7%BB%98%E5%9B%BE8.png" width = '327' alt="图片alt" title="高速计数子模块程序设计框图" /><br>
### 高速计数子模块
该子程序用于计算 *Echo* 信号高电平的持续时间。设 Q 为信号发出后用于统计 *17kHz* 计数脉冲数，则所测距离 L 公式可用下式表示：
$$L=\frac{Q}{2}\times \frac{1}{17kHz}\times 340m/s =Q$$
采用17kHz作为计数脉冲，其周期个数在数值上等于超声波所测距离。通过这种简单的办法，就可以不用进行复杂的乘除法运算结果来占用过多的资源。在程序实现上，将 *17kHz* 波形作为时钟信号触发高速计数寄存器加一运算，寄存器的数据存储方式为：4 位二进制表示 1 位十进制，逢 “9” 进位到上 4 位。
## 显示模块
在数字电路中，数字与字符通常会使用代码或编码的形式来表现，这时就需要使用显示译码器对这些代码进行转译，并通过数码显示屏或数码显示管表达出来，将这些数字或字符直观地显示出来。不同的显示器件，驱动方式各不相同，显示方式也有所差异。比较常用的是类别是七段显示器，七段显示器件包括：发光二极管（LED）、液晶显示器（LCD）、荧光显示器和等离子显示器等。由于LED的驱动电压不高（1.5V~3V），并且工作电流只有十几毫安，这可以直接使用逻辑门电路来驱动，因此在多种嵌入式平台得到了广泛的应用。本项目采用7段LED数码显示管进行显示。
## 调试结果
可定制集成逻辑分析器（**ILA**）IP 核是一款逻辑分析器内核，由 *Xilinx* 公司开发，可用于监控设计中的内部信号。**ILA** IP 核上具备 AXI 接口，可用于调试系统中的使用 *AXI* 总线协议的 IP 核。在 *RTL* 代码设计中引入 **ILA** IP 核需要在顶层文件进行例化。**ILA** IP 核的工作形式是将探针（*Probe*）与待测信号相连接，在同一时钟信号的环境下检测出信号波形。同时待测信号的位宽须在 **ILA** IP 属性面板进行设置。<br><br>
<img src="https://github.com/MongooseOrion/UltraSonic-Design_based-on-FPGA/blob/main/Picture/image.png" width = '700' alt="图片alt" title="测量结果示意" />
## 总结
本系统测试是在理想的实验室环境下进行的，请注意，测量精度可能由于室内测量环境的不同而有所差异。测量精度随距离的增大有减小的趋势，但总体控制在 ***5%*** 以内，尤其在 1 米内的精度很高。然而，超出5米后测量精度急剧下降，造成这种情况的原因可能是：随着距离增大，同尺寸的障碍物可反射超声波的面积相对而言变小了，超声波的频率不足使得回波信号比较微弱并且混有噪声，这就对传感器阈值判断产生了很大影响，从而影响了距离数值。综上，本系统的测距范围在 5 米内，在 1 米内最高可达 ***100%*** 测距精度。
