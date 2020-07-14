module fdivider(
	clk,
	clk_out
);

input clk;
output clk_out;

reg tmp;
reg [20:0] cnt;

assign clk_out = tmp;

always @ (posedge clk)
begin
	if(cnt == 10)
	begin
		cnt <= 0;
		tmp <= ~tmp;
	end
	else
	begin
		cnt <= cnt + 1;
	end
end

endmodule