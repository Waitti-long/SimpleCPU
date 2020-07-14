module ctrl(
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
	imar,emar, // 地址寄存器,
	reg0 // data_reg0
);

input [15:0] cmd,reg0;
input clk,t0,t1,t2,t3,t4,t5,t6,t7,_nop,_ld,_ln,_cp,_st,_shl,_add,_sub,_jz,_jb,_jmp,_xor,_or,_and,_shr,_not,_push,_pop,reset;
output tset,idr_0,edr_0,idr_1,edr_1,idr_bp,edr_bp,idr_sp,edr_sp,iir,eir,ialu,ealu,iram,eram,iaddr,ipc,epc,imar,emar;

reg r_tset,r_idr_0,r_edr_0,r_iir,r_ialu,r_ealu,r_iram,r_eram,r_ipc,r_epc,r_imar,r_idr_1,r_edr_1,r_idr_sp,r_edr_sp,r_idr_bp,r_edr_bp,r_emar,r_eir,r_iaddr;

assign tset = r_tset;
assign idr_0 = r_idr_0;
assign edr_0 = r_edr_0;
assign iir = r_iir;
assign ialu = r_ialu;
assign ealu = r_ealu;
assign iram = r_iram;
assign eram = r_eram;
assign ipc = r_ipc;
assign imar = r_imar;
assign emar = r_emar;
assign idr_1 = r_idr_1;
assign edr_1 = r_edr_1;
assign idr_sp = r_idr_sp;
assign edr_sp = r_edr_sp;
assign idr_bp = r_idr_bp;
assign edr_bp = r_edr_bp;
assign eir = r_eir;
assign iaddr = r_iaddr;
assign epc  = r_epc;

always @ (posedge clk,negedge reset)
begin
	if(!reset)
	begin
		r_tset  <= 0;
		r_idr_0 <= 0;
		r_edr_0 <= 0;
		r_iir   <= 1;
		r_ialu  <= 0; 
		r_ealu  <= 0;
		r_iram  <= 0;
		r_eram  <= 0;
		r_ipc   <= 0; 
		r_imar  <= 0;
		r_idr_1 <= 0; 
		r_edr_1 <= 0; 
		r_idr_sp<= 0;  
		r_edr_sp<= 0;  
		r_idr_bp<= 0;  
		r_edr_bp<= 0;  
		r_emar  <= 0; 
		r_eir   <= 0; 
		r_iaddr <= 0;    
	end
	else
	begin
	case ({t0,t1,t2,t3,t4,t5,t6,t7})
		8'b10000000:begin r_ipc <= 0; end
		8'b01000000:;
		8'b00100000:begin r_eir <= 1; r_imar <= 1;end
		8'b00010000:begin
							r_eir <= 0; r_imar <= 0;
							if(_ln)
							begin
								r_emar <= 1;
								case(cmd[10:8])
									1:r_idr_0 <= 1;
									2:r_idr_bp <= 1;
									3:r_idr_sp <= 1;
									4:r_idr_1 <= 1;
								endcase
							end
							else if(_st)
							begin
								r_iaddr <= 1;r_emar <= 1;
							end
							else if(_ld)
							begin
								r_iaddr <= 1;r_emar <= 1;
							end
							else if(_cp)
							begin
								case(cmd[10:8])
									1:r_idr_0 <= 1;
									2:r_idr_bp <= 1;
									3:r_idr_sp <= 1;
									4:r_idr_1 <= 1;
								endcase
								case(cmd[2:0])
									1:r_edr_0 <= 1;
									2:r_edr_bp <= 1;
									3:r_edr_sp <= 1;
									4:r_edr_1 <= 1;
								endcase
							end
							else if(_shl || _add || _sub || _xor || _or || _and || _shr || _not)
							begin
								
								r_ialu <= 1;
								
								case(cmd[10:8])
									0:r_emar <= 1;
									1:r_edr_0 <= 1;
									2:r_edr_bp <= 1;
									3:r_edr_sp <= 1;
									4:r_edr_1 <= 1;
								endcase
							end
							else if(_jz)
							begin
								if(reg0 == 0)
								begin
									r_emar <= 1;
									r_epc <= 1;
								end
							end
							else if(_jb)
							begin
								if(!(reg0 >= 0 && reg0 < 128))
								begin
									r_emar <= 1;
									r_epc <= 1;
								end
							end
							else if(_jmp)
							begin
								r_emar <= 1;
								r_epc <= 1;
							end
						end
		8'b00001000:begin
							if(_ln)
							begin
								r_emar <= 0;
								case(cmd[10:8])
									1:r_idr_0 <=  0;
									2:r_idr_bp <= 0;
									3:r_idr_sp <= 0;
									4:r_idr_1 <=  0;
								endcase
							end
							else if(_st)
							begin
								r_iaddr <= 0;r_emar <= 0;
								case(cmd[10:8])
									1:r_edr_0 <=  1;
									2:r_edr_bp <= 1;
									3:r_edr_sp <= 1;
									4:r_edr_1 <=  1;
								endcase
								r_iram <= 1;
							end
							else if(_ld)
							begin
								r_iaddr <= 0;r_emar <= 0;
								case(cmd[10:8])
									1:r_idr_0 <=  1;
									2:r_idr_bp <= 1;
									3:r_idr_sp <= 1;
									4:r_idr_1 <=  1;
								endcase
								r_eram <= 1;
							end
							else if(_cp)
							begin
								case(cmd[10:8])
									1:r_idr_0 <=  0;
									2:r_idr_bp <= 0;
									3:r_idr_sp <= 0;
									4:r_idr_1 <=  0;
								endcase
								case(cmd[2:0])
									1:r_edr_0 <=  0;
									2:r_edr_bp <= 0;
									3:r_edr_sp <= 0;
									4:r_edr_1 <=  0;
								endcase
							end
							else if(_shl || _add || _sub || _xor || _or || _and || _shr || _not)
							begin
								
									
								r_ialu <= 0;
						
							end
							else if(_jz)
							begin
								if(reg0 == 0)
								begin
									r_emar <= 0;
									r_epc <= 0;
								end
							end
							else if(_jb)
							begin
								if(!(reg0 >= 0 && reg0 < 128))
								begin
									r_emar <= 0;
									r_epc <=  0;
								end
							end
							else if(_jmp)
							begin
								r_emar <= 0;
								r_epc <= 0;
							end
						end
		8'b00000100:begin
							if(_st)
							begin
								case(cmd[10:8])
									1:r_edr_0 <=  0;
									2:r_edr_bp <= 0;
									3:r_edr_sp <= 0;
									4:r_edr_1 <=  0;
								endcase
								r_iram <= 0;
							end
							else if(_ld)
							begin
								case(cmd[10:8])
									1:r_idr_0 <=  0;
									2:r_idr_bp <= 0;
									3:r_idr_sp <= 0;
									4:r_idr_1 <=  0;
								endcase
								r_eram <= 0;
							end
							else if(_shl || _add || _sub || _xor || _or || _and || _shr || _not)
							begin
								case(cmd[10:8])
									0:r_emar <=   0;
									1:r_edr_0 <=  0;
									2:r_edr_bp <= 0;
									3:r_edr_sp <= 0;
									4:r_edr_1 <=  0;
								endcase
								r_idr_0 <= 1;
								r_ealu <= 1;
							end
						end	
		8'b00000010:begin
							if(_shl || _add || _sub || _xor || _or || _and || _shr || _not)
							begin
								r_idr_0 <= 0;
								r_ealu <=  0;
							end
						end
		8'b00000001:begin

						r_ipc <= 1; end
	endcase
	end
end

endmodule