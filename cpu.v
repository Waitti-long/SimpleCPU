module cpu(
	clk,
	reset,
	// Obersver
	o_data,
	o_cmd,
	o_reg0,
	o_reg1,
	o_sp,
	o_bp,
	o_ip,
	o_mar,
	o_buff_data,
	o_buff_code
);
	
input clk,reset;

output [15:0] o_data,o_cmd,o_reg0,o_reg1,o_sp,o_bp,o_ip,o_mar,o_buff_data,o_buff_code;

wire t0,t1,t2,t3,t4,t5,t6,t7;
wire _nop,_ld,_ln,_cp,_st,_shl,_add,_sub,_jz,_jb,_jmp,_xor,_or,_and,_shr,_not,_push,_pop;
wire tset,idr_0,edr_0,iir,eir,ialu,ealu,iram,eram,iaddr,ipc,epc,imar,emar,idr_1,edr_1,idr_bp,edr_bp,idr_sp,edr_sp;

wire [15:0] cmd,data_reg0,data_reg1,data_sp,data_bp,ip,addr;

wire [15:0] data;

assign o_data = data;
assign o_cmd = cmd;
assign o_reg0 = data_reg0;
assign o_reg1 = data_reg1;
assign o_sp = data_sp;
assign o_bp = data_bp;
assign o_ip = ip;

lpm_rom coderom(.address(ip),.inclock(clk),.q(cmd));
defparam coderom.lpm_width = 16;
defparam coderom.lpm_widthad = 16;
defparam coderom.lpm_outdata = "UNREGISTERED";
// defparam iram.lpm_indata = "REGISTERED";
defparam coderom.lpm_address_control = "REGISTERED";
defparam coderom.lpm_file = "code.mif";

beat _beat(clk,reset,t0,t1,t2,t3,t4,t5,t6,t7);			
pc _pc(clk,reset,ipc,epc,data,ip);
mar _mar(clk,imar,emar,data,o_mar);
ir _ir(	clk,iir,eir,code,
			_nop,_ld,_ln,_cp,_st,_shl,_add,_sub,_jz,_jb,_jmp,_xor,_or,_and,_shr,_not,_push,_pop,
			data,
			o_buff_data,o_buff_code);
dr _reg0(clk,idr_0,edr_0,data,data_reg0);
dr _reg1(clk,idr_1,edr_1,data,data_reg1);
dr _regsp(clk,idr_sp,edr_sp,data,data_sp);
dr _regbp(clk,idr_bp,edr_bp,data,data_bp);

ctrl _ctrl(
	clk, // 时钟,
	reset,
	t0,t1,t2,t3,t4,t5,t6,t7, // 节拍
	_nop,_ld,_ln,_cp,_st,_shl,_add,_sub,_jz,_jb,_jmp,_xor,_or,_and,_shr,_not,_push,_pop,// 指令
	cmd, // cmd
	tset,// 节拍归零
	idr_0,edr_0, // reg0
	idr_1,edr_1, // reg1
	idr_bp,edr_bp, // bp
	idr_sp,edr_sp, // sp
	iir,eir, // 译址器
	ialu,ealu, // alu
	iram,eram,iaddr, // ram
	ipc,epc, // ip
	imar,emar // 地址寄存器
);			
	
endmodule