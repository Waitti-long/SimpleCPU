module mar(
	clk,
	imar,
	emar,
	data,
	o_addr
);

input clk,imar,emar;
inout [15:0] data;
output [15:0] o_addr;

reg [15:0] buff,tmp;

assign data = tmp;
assign o_addr = buff;

always @ (posedge clk)
begin
	if(imar)
	begin
		buff <= data;
	end
	if(emar)
	begin
		tmp <= buff;
	end
	else
	begin
		tmp <= 16'bZZZZZZZZZZZZZZZZ;
	end
end


endmodule