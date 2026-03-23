# ISA
Dimensions of ISA
- Class of ISA
- Mem Addressing：例如Byte Addressing
- Addressing Modes (寻址模式，例如Imm, Reg, Displacement)
- Types and sizes of operands
- Operations
- Control Flow Instructions
- Encoding Style
Load-Store ISA & Register-Memory ISA
- RISC-V是Load-Store ISA，说明任何操作都只能直接在Reg上进行
- 而Reg-Mem ISA：操作数可以直接来自于内存
Mem Addressing
- 因为在使用BUS对Mem进行读取时，往往以Block为单位进行读取，而这个读取是Aligned的
- 所以存储时就要进行Alignment，如果有一个横跨多个Block的数据，那么无法一次进行读取，而如果剩下来的数据同样需要Alignment的话，就会占用更多的块
- 对齐的规则：1-byte的地址是1的倍数，2-byte地址是2的倍数，4-byte的地址是4的倍数......
Addressing Modes
- 例如Register就是使用寄存器中的值作为地址
- Immediate就是直接访问给定的内存地址
- Displacement就是访问register + constant
ISA Operations
- Data Transfer: Load/Store/MOV/...
- Arithmetic: add/sub/...
ISA Encoding
- Fixed Length: RISC-V/MIPS/ARM
- Variable Length: 80x86
所以从Implementation的角度来看，需要关注ISA, Organization , Hardware三个方面的要点

# Trends and performance
5 Implementation technologies
- Integrated circuit logic
- Semi-con DRAM
- Semi-con Flash
- Magnetic Disk Tech
- Network Tech
Energy Efficiency
- $Power_{dynamic} \propto 1/2 \times Capacitive\;load \times Voltage^2 \times Frequency\;switched$
	- 其中的1/2 是逻辑的忙碌度，如果空闲则不耗能
	- 电容负载：如果晶体管缩小，那么电容就会下降，功率下降
- 注意Power和Dynamic之间的关系
	- 也就是，如果我们放慢Clock Rate，虽然Power会下降，但是整体的Energy不会发生改变
	- $energy = power \times exec-time$ 
- How to economize energy
	- 不活跃的模块可以关闭时钟
	- DVFS(Dynamic Volt and Freq Scaling)：在低活动时间降低Frequency
	- Overclocking: 提升clockrate：短时间内快速执行
	- Design for typical cases: 对不同module提供不同的Power Modes
Chip Manufacturing
- $Cost\;of\;die = \frac{Cost\;of\;wafer}{Dies\;per\;wafer\times Die\;yield}$
- 在wafer上进行切割，Dies per wafer是wafer能产出的dies数量，die yield是良率
- yield learning curve就是在芯片制造的过程中良率不断上升的整个过程
- 可以添加Redundancy(尤其是DRAM/SRAM)，多生产的部件可以以降低出现问题的概率
- Fault->Error->Failure: 越来越严重，fault指的是底层是否发生了问题(例如ALU计算结果有没有问题)(有可能并没有用到这个结果)，error指的是这个结果确实被用到了，而Failure指的是这个结果可能确实导致了一些执行operation的问题
Module Availability:
- MTTF(Mean Time To Failure)：其实就是正常运行的平均时长
- MTTR(Mean Time To Repair)
- MTBF(Mean Time Between Failures) = MTTF + MTTR
Availability：在给定时间段内处于Available工作状态的概率：$\frac{MTTF}{MTBF}$
RAID: Redundant Array of Independent Disks
- Parity可以作为常见的校验与数据恢复手段，利用XOR的数学特性，将Parity Bit与其他正确的位置做XOR，得到Error Bit的原始值
- RAID1: Mirroring
	- 让两块硬盘互为备份
	- 空间利用率过低
	- one logical r/w $\leftrightarrow$ two physical r/w
	- 100% Space Overhead
- RAID6: Row-Diagonal Parity
	- 使用P校验与Q校验
	- 可以接受两块盘中同时错
	- 使用的就是行Parity + Diagonal Parity(单向的对角线)
- 注意对角线是可以从左侧和右侧绕回的，而不能从上面和右边绕回
- 默认硬盘架构为disk1->disk2->...->P disk -> Q disk
