RISC Architecture
Two Critical Performance Techniques:
- Instruction-Level Parallelism(Pipelining and Multi-Issue)
- Caching
还有其他级别的Parallelism， 例如Process/Thread-Level Parallelism
CPI: Clock Cycle per Instruction, $CPI \geq 1$

Multi-Issue:
- 使用了多重Datapath
- 可以在并行状态下执行多条指令
- CPI甚至可以到1以下

Storage
- CPU Registers $\leftrightarrow$ Memory $\leftrightarrow$ I/O Devices
- 在CPU Registers和Memory之间添加一个Cache层级，提供了Faster Temporary Storage

Amdahl's Law
$Sp = \frac{ExecTime_{old}}{ExecTime_{new}} = \frac{1}{(1-frac_{enhance}) + \frac{frac_{enhance}}{sp_{enhance}}}$
$frac_{enhance}$是代码中能被并行的部分
例如Multi-Core CPU中增加核的数量，就是增加$sp_{enhance}$，这个公式可以帮助我们理解什么时候不用通过增加核来进行优化(受到可并行指令占比的影响)

Types of Computers
- Real Time Performance:
	- 指的是maximum execution time for each application segment
	- 也就是任务必须在严格期限内完成
- Soft Real-time:
	- 尽量在期限内完成，偶尔超时不会导致崩溃
	- 但是超时也会影响用户体验
- PMD(Personal Mobile Devices)
	- 考虑Memory Efficiency与Energy Efficiency
- Desktop
	- Combination of Price and Performance
- Server
	- 大规模的文件与计算服务
	- 可以提供enterprise computing

Parallelism
- Application Parallelism(算法设计的层面)
	- Data-Level(DLP)
		- 许多数据被同时处理
	- Task-Level(TLP)
		- 独立处理的tasks
		- 将一个大的工作转化为不同的tasks
- Hardware Parallelism
	- Instruction-Level Parallelism (ILP)
	- Thread-Level Parallelism (TLP)
	- Request-Level Parallelism (RLP)

ILP
- 初始的是pipelining
- 还有speculative exec(例如分支预测)
	- 就是提前完成一部分的工作
	- 假如预测有错，就进行flush即可
Vector Arch
- 支持一个Vector Instruction进行多重数据的处理