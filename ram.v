module ram(
	clk,
	iram,
	eram,
	iaddr,
	data,
	o_addr
);

input clk,iram,eram,iaddr;
inout [15:0] data;

output [15:0] o_addr;

reg [15:0] mem [0:127];

reg [15:0] addr, tmp;

assign data = tmp;
assign o_addr = addr;

always @ (posedge clk)
begin
	if(iaddr)addr <= data;
	if(iram)
	begin
		mem[addr] <= data;
	end
end

always @ (addr,eram)
begin
	if(eram)
	begin
		tmp <= mem[addr];
	end
	else
	begin
		tmp <= 16'bZZZZZZZZZZZZZZZZ;
	end
end

endmodule