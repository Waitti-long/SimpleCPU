module alu(
	clk,
	ialu,
	ealu,
	_shl,_add,_sub,_xor,_or,_and,_shr,_not,
	data_a,
	data
);

input ialu,ealu,_shl,_add,_sub,_xor,_or,_and,_shr,_not,clk;
input [15:0] data_a;
inout [15:0] data;

reg [15:0] res,tmp;

assign data = tmp;

always @ (posedge clk)
begin
	if(ialu)
	begin
	case({_shl,_add,_sub,_xor,_or,_and,_shr,_not})
		8'b10000000: res <= (data_a << data);
		8'b01000000: res <= (data_a + data);
		8'b00100000: res <= (data_a - data);
		8'b00010000: res <= (data_a ^ data);
		8'b00001000: res <= (data_a | data);
		8'b00000100: res <= (data_a & data);
		8'b00000010: res <= (data_a >> data);
		8'b00000001: res <= ~data_a;
	endcase
	end
end

always @ (res,ealu)
begin
	if(ealu)
	begin
		tmp <= res;
	end
	else
	begin
		tmp <= 16'bZZZZZZZZZZZZZZZZ;
	end
end


endmodule