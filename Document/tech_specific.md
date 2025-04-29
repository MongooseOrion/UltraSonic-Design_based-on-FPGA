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
# 超声波测距原理

超声波测距基于“飞行时间”（Time-of-Flight，TOF）原理：向空气中发射一道已知频率 $f$（HC-SR04 为 $40\,\text{kHz}$）的超声波脉冲，波在遇到目标表面时被反射，回波返回到发射点。设发射到接收整过程经历的时间为 $t$，声速为 $v$（在 $20 ^{\circ}\text{C}$ 、1 atm 条件下 $v \approx 343 \text{m/s}$，其温度依赖关系可近似表示为 $v(T)\approx331+0.6\,T\,[^{\circ}\text{C}]$），则传感器与目标之间的单程距离 $d$ 满足

$$d = \frac{v\,t}{2}$$

异步误差来自声速估计、振荡起始抖动、回波判决阈值以及定时分辨率，后两者通常由数字逻辑实现方式决定；若用 FPGA 的高频时钟计数，距离分辨率为

$$\Delta d = \frac{v}{2f_\text{clk}}$$

其中 $f_\text{clk}$ 为对 ECHO 脉冲计数的系统时钟频率。例如，$100\text{MHz}$ 时钟对应 $\Delta d \approx 1.7 \mathrm{mm}$。

## HC-SR04 传感器的工作时序

HC-SR04 集成一个 40 kHz 压电换能器对、模拟驱动放大链及内部比较器逻辑，提供两根数字 I/O：**TRIG**（输入）和 **ECHO**（输出）。典型测距周期如下：

1. **触发**：向 TRIG 端口施加不少于 10 µs 的高电平脉冲，片上逻辑复位计时器并产生 8 个 40 kHz 正弦包络（约 200 µs）。
2. **飞行时间窗**：声波发射后立即启动 ECHO 定时器；当换能器接收到足够大的回波能量并越过比较器阈值时，ECHO 引脚被拉高；若在最大发电后约 38 ms（对应 4 m 空程）仍无回波，则 ECHO 保持低电平表示“超出量程”。
3. **ECHO 脉冲宽度**：ECHO 的高电平持续时间即总往返时间 $t$。外部控制器只需测量此宽度即可按上式计算距离。

## 基于 FPGA 的距离计算实现思路

FPGA 的高并发与确定性时序非常适合超声 TOF 计数。常见实现流程为：

  1. 产生 TRIG 脉冲；
  2. 在同一时钟域内检测 ECHO 上升沿后启动 32 位递增计数器；
  3. 检测 ECHO 下降沿后锁存计数值 $N$；
  4. 用硬件乘法或移位-加法完成

$$d = \frac{v}{2 f_\text{clk}}\,N$$

为了避免多径干扰及目标极近（<2 cm）场区饱和，可在 TRIG 与 ECHO 计时之间插入 200µs “发射盲区锁定”窗口；在距离滤波阶段采用一阶 IIR 或卡尔曼滤波可减小抖动并提供速度估计。

通过该框架，HC-SR04 与 FPGA 的配合可在 2cm–400cm 范围内实现亚厘米级解析度和高测距频率（理论上 >50 Hz，受换能器回波尾部与目标吸收特性限制）。