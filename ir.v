module ir(
	clk,
	iir,
	eir,
	icode,
	code,
	_nop,_ld,_ln,_cp,_st,_shl,_add,_sub,_jz,_jb,_jmp,_xor,_or,_and,_shr,_not,_push,_pop,
	data,
	o_buff_data
);

input clk,iir,eir,icode;

input [15:0] code;

output _nop,_ld,_ln,_cp,_st,_shl,_add,_sub,_jz,_jb,_jmp,_xor,_or,_and,_shr,_not,_push,_pop;

output [15:0] o_buff_data;

inout [15:0] data;

reg [17:0] buff;
reg [15:0] buff_code;
reg [15:0] buff_data,tmp;

assign data = tmp;	
assign o_buff_data = buff_data;

assign _nop = buff[0];
assign _ld  = buff[1];
assign _ln  = buff[2];
assign _cp  = buff[3];
assign _st  = buff[4];
assign _shl = buff[5];
assign _add = buff[6];
assign _sub = buff[7];
assign _jz  = buff[8];
assign _jb  = buff[9];
assign _jmp = buff[10];
assign _xor= buff[11];
assign _or = buff[12];
assign _and= buff[13];
assign _shr = buff[14];
assign _not= buff[15];
assign _push= buff[16];
assign _pop = buff[17];

always @ (posedge clk)
begin
	if(iir)
	buff_code <= code;
	if(eir)
	begin
		tmp <= buff_data;
	end
	else
	begin
		tmp <= 16'bZZZZZZZZZZZZZZZZ;
	end
end

always @ (buff_code)
begin
	case(buff_code[15:11])
		0:  buff <= 18'b000000000000000001;
		1:	 buff <= 18'b000000000000000010;
		2:	 buff <= 18'b000000000000000100;
		3:	 buff <= 18'b000000000000001000;
		4:  buff <= 18'b000000000000010000;
		5:  buff <= 18'b000000000000100000;
		6:  buff <= 18'b000000000001000000;
		7:  buff <= 18'b000000000010000000;
		8:  buff <= 18'b000000000100000000;
		9:  buff <= 18'b000000001000000000;
		10: buff <= 18'b000000010000000000;
		11: buff <= 18'b000000100000000000;
		12: buff <= 18'b000001000000000000;
		13: buff <= 18'b000010000000000000;
		14: buff <= 18'b000100000000000000;
		15: buff <= 18'b001000000000000000;
		16: buff <= 18'b010000000000000000;
		17: buff <= 18'b100000000000000000;
		default: buff <= 1;
	endcase;
	buff_data <= {8'b00000000, buff_code[7:0]};
end

endmodule