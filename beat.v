module beat(
	clk,
	reset,
	t0,t1,t2,t3,t4,t5,t6,t7
);

input clk, reset;
output t0,t1,t2,t3,t4,t5,t6,t7;

reg [7:0] cnt;

assign t0 = cnt[0];
assign t1 = cnt[1];
assign t2 = cnt[2];
assign t3 = cnt[3];
assign t4 = cnt[4];
assign t5 = cnt[5];
assign t6 = cnt[6];
assign t7 = cnt[7];

always @ (posedge clk, negedge reset)
begin
	if(!reset)
	begin
		cnt = 1;
	end
	else
	begin
		cnt <= {cnt[6:0], cnt[7]};
	end
end


endmodule