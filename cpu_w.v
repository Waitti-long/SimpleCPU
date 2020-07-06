module cpu_w(
	clock,
	reset,
	// Observer
	o_jp,
	o_ip,
	o_addr,
	o_sp,
	o_cmd,
	o_memory,
	o_ss_data,
	o_reg0,
	o_reg1,
	o_bp,
	o_data_trans
);

input clock;
input reset;
output [15:0] o_jp, o_ip, o_addr, o_sp,o_cmd,o_ss_data, o_memory, o_reg0,o_reg1,o_bp,o_data_trans;

reg [15:0] ip, addr, sp, jp; // 指令计数器，地址计数器，栈顶指针，节拍

reg [15:0] reg0, bp, reg1; // 寄存器0，栈底指针，寄存器1

reg [15:0] data_trans, ds_wd, ss_wd; // CP中间数据，写DS，写SS

reg [4:0] shl_cnt, shr_cnt; // 左移位数, 右移位数

reg [15:0] add_num, sub_num; // 加缓存，减缓存

reg [15:0] xor_mid, or_mid, and_mid; // 异或中间量，或中间量，与中间量

wire [15:0] cmd, memory, ss_data; // 指令， DS数据，SS数据

reg ds_w,ss_w; // 写DS控制位，写SS控制位


lpm_rom iram(.address(ip),.inclock(clock),.q(cmd));
defparam iram.lpm_width = 16;
defparam iram.lpm_widthad = 16;
defparam iram.lpm_outdata = "UNREGISTERED";
// defparam iram.lpm_indata = "REGISTERED";
defparam iram.lpm_address_control = "REGISTERED";
defparam iram.lpm_file = "code.mif";

lpm_ram_dq dram(.data(ds_wd),.address(addr),.we(ds_w),.inclock(clock),.q(memory));
defparam dram.lpm_width = 16;
defparam dram.lpm_widthad = 16;
defparam dram.lpm_outdata = "UNREGISTERED";
defparam dram.lpm_indata = "REGISTERED";
defparam dram.lpm_address_control = "REGISTERED";
defparam dram.lpm_file = "data.mif";

lpm_ram_dq sram(.data(ss_wd),.address(sp),.we(ss_w),.inclock(clock),.q(ss_data));
defparam sram.lpm_width = 16;
defparam sram.lpm_widthad = 16;
defparam sram.lpm_outdata = "UNREGISTERED";
defparam sram.lpm_indata = "REGISTERED";
defparam sram.lpm_address_control = "REGISTERED";
defparam sram.lpm_file = "stack.mif";


assign o_jp = jp;
assign o_ip = ip;
assign o_addr = addr;
assign o_sp = sp;
assign o_cmd = cmd;
assign o_memory = memory;
assign o_ss_data = ss_data;
assign o_bp = bp;
assign o_reg0 = reg0;
assign o_reg1 = reg1;
assign o_data_trans = data_trans;


always @ (posedge clock,negedge reset)
begin
	if(!reset)
	begin
		jp <= 0;
		
		ip <= 0;
		addr <= 0;
		sp <= 0;
		bp <= 0;
		
		ds_w <= 0;
		ss_w <= 0;

		reg0 <= 0;
		reg1 <= 0;
		data_trans <= 0;
		
	end
	else
	begin
		case (jp)
		// 取址
		0: jp <= 1;
		
		1: begin
			case (cmd[15:11])
				default: jp <= 2;
			endcase
			end
			
		2: begin 
			case (cmd[15:11])
				default: begin
							ip <= ip + 1;
							jp <= 0;
							end
				// LD 从RAM加载数据到寄存器			
				1:	begin 
					addr[7:0] <= cmd[7:0];
					jp <= 3;
					end
				// LN 加载立即数到寄存器低8位	
				2: begin
					case (cmd[10:8])
						1: reg0[7:0] <= cmd[7:0];
						2: bp[7:0] <= cmd[7:0];
						3: sp[7:0] <= cmd[7:0];
						4: reg1[7:0] <= cmd[7:0];
					endcase
					jp <= 0;
					ip <= ip + 1;
					end
				// CP 复制寄存器数据到另一个寄存器	
				// 缓存
				3: begin
					case (cmd[2:0])
						1: data_trans <= reg0;
						2: data_trans <= bp;
						3: data_trans <= sp;
						4: data_trans <= reg1;
					endcase
					jp <= 3;
					end
				// ST 复制寄存器数据到RAM	
				4: begin
						addr[7:0] <= cmd[7:0];
						case (cmd[10:8])
							1: ds_wd <= reg0;
							2: ds_wd <= bp;
							3: ds_wd <= sp;
							4: ds_wd <= reg1;
						endcase
						jp <= 3;
					end
				// SHL $0左移寄存器位或立即数位
				5: begin
						case (cmd[10:8])
						0: shl_cnt <= cmd[3:0];
						1: shl_cnt <= reg0[3:0];
						2:	shl_cnt <= bp[3:0];
						3:	shl_cnt <= sp[3:0];
						4:	shl_cnt <= reg1[3:0];
						endcase
						jp <= 3;
					end
				// ADD $0加寄存器或立即数
				6: begin
				      case (cmd[10:8])
						0: add_num <= {8'b00000000,cmd[7:0]};
						1: add_num <= reg0;
						2:	add_num <= bp;
						3:	add_num <= sp;
						4: add_num <= reg1;
						endcase
						jp <= 3;
					end
				// SUB	
				7: begin
						case (cmd[10:8])
						0: sub_num <= {8'b00000000,cmd[7:0]};
						1: sub_num <= reg0;
						2:	sub_num <= bp;
						3:	sub_num <= sp;
						4: sub_num <= reg1;
						endcase
						jp <= 3;
					end
				// JZ reg0为0时跳转
				8: begin
						if (reg0 != 0)
						begin
							jp <= 0;
							ip <= ip + 1;
						end
						else
						begin
							case (cmd[10:8])
								0: ip <= {8'b00000000,cmd[7:0]};
								1: ip <= reg0;
								2:	ip <= bp;
								3:	ip <= sp;
								4: ip <= reg1;
							endcase
								jp <= 0;
						end
					end
				// JB reg0<0时跳转	
				9: begin
						if (reg0 >= 0 && reg0 < 128)
						begin
							jp <= 0;
							ip <= ip + 1;
						end
						else
						begin
							case (cmd[10:8])
								0: ip <= {8'b00000000,cmd[7:0]};
								1: ip <= reg0;
								2:	ip <= bp;
								3:	ip <= sp;
								4: ip <= reg1;
							endcase
								jp <= 0;
						end
					end
				// JMP 无条件跳转
				10:	begin
						case (cmd[10:8])
								0: ip <= {8'b00000000,cmd[7:0]};
								1: ip <= reg0;
								2:	ip <= bp;
								3:	ip <= sp;
								4: ip <= reg1;
						endcase
								jp <= 0;
					end
				// XOR
				11: begin
						case (cmd[10:8])
								0: xor_mid <= {8'b00000000,cmd[7:0]};
								1: xor_mid <= reg0;
								2:	xor_mid <= bp;
								3:	xor_mid <= sp;
								4: xor_mid <= reg1;
						endcase
						jp <= 3;
					end
					// OR
				12: begin
						case (cmd[10:8])
								0: or_mid <= {8'b00000000,cmd[7:0]};
								1: or_mid <= reg0;
								2:	or_mid <= bp;
								3:	or_mid <= sp;
								4: or_mid <= reg1;
						endcase
						jp <= 3;
					end
					// AND
				13: begin
						case (cmd[10:8])
								0: and_mid <= {8'b00000000,cmd[7:0]};
								1: and_mid <= reg0;
								2:	and_mid <= bp;
								3:	and_mid <= sp;
								4: and_mid <= reg1;
						endcase
						jp <= 3;
					end	
				// SHR $0右移寄存器位或立即数位
				14: begin
						case (cmd[10:8])
						0: shr_cnt <= cmd[3:0];
						1: shr_cnt <= reg0[3:0];
						2:	shr_cnt <= bp[3:0];
						3:	shr_cnt <= sp[3:0];
						4:	shr_cnt <= reg1[3:0];
						endcase
						jp <= 3;
					end
				// NOT
				15: begin
						reg0 <= ~reg0;
						ip <= ip + 1;
						jp <= 0;
					end
				// PUSH
				16: begin
						case (cmd[10:8])
							0: ss_wd <= {8'b00000000, cmd[7:0]};
							1: ss_wd <= reg0;
							2: ss_wd <= bp;
							3: ss_wd <= sp;
							4: ss_wd <= reg1;
						endcase
						sp <= sp + 1;
						ss_w <= 1;
						jp <= 3;
					end
				// POP
				17: begin
						case (cmd[10:8])
							1: reg0 <= ss_data;
							2: bp <= ss_data;
							3: sp <= ss_data;
							4: reg1 <= ss_data;
						endcase
						sp <= sp - 1;
						jp <= 0;
						ip = ip + 1;
					end	
			endcase
			end
			
		3: begin
			case (cmd[15:11])
				// LD 读RAM
				1: jp <= 4;
				
				// CP 读缓存
				3: begin
					case (cmd[10:8])
						1: reg0 <= data_trans;
						2: bp <= data_trans;
						3: sp <= data_trans;
						4: reg1 <= data_trans;
					endcase
					jp <= 0;
					ip <= ip + 1;
					end
				// ST
				4: jp <= 4;
				// SHL
				5: begin
					case (shl_cnt)
						0: reg0 <= reg0; 
						1:	begin reg0[15:1] <= reg0[14:0]; reg0[0] <= 0; end
						2: begin reg0[15:2] <= reg0[13:0]; reg0[1:0] <= 0; end
						3:	begin reg0[15:3] <= reg0[12:0]; reg0[2:0] <= 0; end
						4:	begin reg0[15:4] <= reg0[11:0]; reg0[3:0] <= 0; end
						5:	begin reg0[15:5] <= reg0[10:0]; reg0[4:0] <= 0; end
						6:	begin reg0[15:6] <= reg0[9:0]; reg0[5:0] <= 0; end
						7:	begin reg0[15:7] <= reg0[8:0]; reg0[6:0] <= 0; end
						8:	begin reg0[15:8] <= reg0[7:0]; reg0[7:0] <= 0; end
						9:	begin reg0[15:9] <= reg0[6:0]; reg0[8:0] <= 0; end
						10:	begin reg0[15:10] <= reg0[5:0]; reg0[9:0] <= 0; end
						11:	begin reg0[15:11] <= reg0[4:0]; reg0[10:0] <= 0; end
						12:	begin reg0[15:12] <= reg0[3:0]; reg0[11:0] <= 0; end
						13:	begin reg0[15:13] <= reg0[2:0]; reg0[12:0] <= 0; end
						14:	begin reg0[15:14] <= reg0[1:0]; reg0[13:0] <= 0; end
						15:	begin reg0[15] <= reg0[0]; reg0[14:0] <= 0; end
					endcase
					jp <= 0;
					ip <= ip + 1;
					end
				// ADD	
				6: begin
						reg0 <= add_num + reg0;
						jp <= 0;
						ip <= ip + 1;
					end
				// SUB	
				7: begin
						reg0 <= reg0 - sub_num;
						jp <= 0;
						ip <= ip + 1;
					end
				// XOR
				11: begin
						case (cmd[10:8])
								0: reg0 <= reg0 ^ xor_mid;
								1: reg0 <= reg0 ^ xor_mid;
								2:	reg0 <= reg0 ^ xor_mid;
								3:	reg0 <= reg0 ^ xor_mid;
								4: reg0 <= reg0 ^ xor_mid;
						endcase
						jp <= 0;
						ip <= ip + 1;
					end
				// OR
				12: begin
						case (cmd[10:8])
								0: reg0 <= reg0 | or_mid;
								1: reg0 <= reg0 | or_mid;
								2:	reg0 <= reg0 | or_mid;
								3:	reg0 <= reg0 | or_mid;
								4: reg0 <= reg0 | or_mid;
						endcase
						jp <= 0;
						ip <= ip + 1;
					end
				// AND
				13: begin
						case (cmd[10:8])
								0: reg0 <= reg0 & and_mid;
								1: reg0 <= reg0 & and_mid;
								2:	reg0 <= reg0 & and_mid;
								3:	reg0 <= reg0 & and_mid;
								4: reg0 <= reg0 & and_mid;
						endcase
						jp <= 0;
						ip <= ip + 1;
					end
				// SHR	
				14: begin
						reg0 <= (reg0 >> shr_cnt);
						jp <= 0;
						ip <= ip + 1;
					end
				// PUSH
				16: jp <= 4;
					
			endcase
			end
			
		4: begin
			case (cmd[15:11])
				// LD 写寄存器
				1: begin 
					case (cmd[10:8])
						1: reg0 <= memory;
						2: bp <= memory;
						3: sp <= memory;
						4: reg1 <= memory;
					endcase
					jp <= 0;
					ip <= ip + 1;
				end
				// ST
				4: begin
					ds_w <= 1;
					jp <= 5;
					end
				// PUSH
				16: begin
						ss_w <= 0;
						jp <= 0;
						ip <= ip + 1;
					end
			endcase
			end
			
		5: begin
			case (cmd[15:11])
				4: begin
					ds_w <= 0;
					jp <= 0;
					ip <= ip + 1;
					end
			endcase
			end
			
		endcase
				
		end
end

endmodule