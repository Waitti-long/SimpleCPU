# SimpleCPU
2020-数电-课程设计

### 寄存器对照表

| 寄存器代号 | 作用     |
| ---------- | -------- |
| 0          | 常数标记 |
| 1          | $0       |
| 2          | BP       |
| 3          | SP       |
| 4          | $1       |

### 指令集

```
r: 寄存器
a: 存储器地址
n: 常数
```

| 指令编号 | 指令名 | 参数  | 描述                       |
| -------- | ------ | ----- | -------------------------- |
| 0        | NOP    |       | 空指令                     |
| 1        | LD     | r a   | 从储存器中加载数据到寄存器 |
| 2        | LN     | r n   | 加载常数到寄存器低八位     |
| 3        | CP     | r1 r2 | 复制r2数据到r1             |
| 4        | ST     | r a   | 将寄存器数据写到存储器中   |
| 5        | SHL    | r/n   | 左移                       |
| 6        | ADD    | r/n   | 加，\$0 = \$0 + r          |
| 7        | SUB    | r/n   | 减                         |
| 8        | JZ     | r/n   | \$0等于零跳转              |
| 9        | JB     | r/n   | \$0小于零跳转              |
| 10       | JMP    | r/n   | 无条件跳转                 |
| 11       | XOR    | r/n   | 按位异或                   |
| 12       | OR     | r/n   | 按位或                     |
| 13       | AND    | r/n   | 按位与                     |
| 14       | SHR    | r/n   | 右移                       |
| 15       | NOT    |       | 按位取非                   |
| 16       |        |       |                            |
| 17       |        |       |                            |
| 18       |        |       |                            |

