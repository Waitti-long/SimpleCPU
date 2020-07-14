module dr(
	clk,
	idr,
	edr,
	data,
	data_out
);

input clk,idr,edr;
inout [15:0] data;
output [15:0] data_out;

reg [15:0] regq,tmp;

assign data = tmp;
assign data_out = regq;

always @ (posedge clk)
begin
	if(idr)
	begin
		regq <= data;
	end
end

always @ (regq,edr)
begin
	if(edr)
	begin
		tmp <= regq;
	end
	else
	begin
		tmp <= 16'bZZZZZZZZZZZZZZZZ;
	end
end


endmodule