module ram(
	clk,
	iram,
	eram,
	iaddr,
	data
);

input clk,iram,eram,iaddr;
inout [15:0] data;

reg [15:0] mem [0:127];

reg [15:0] addr, tmp;

assign data = tmp;

always @ (posedge clk)
begin
	if(iaddr)addr <= data;
	if(iram)
	begin
		mem[addr] <= data;
	end
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