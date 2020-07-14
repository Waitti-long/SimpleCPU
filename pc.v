module pc(
	clk,
	reset,
	ipc,
	epc,
	data,
	pcout
);

input clk, reset, ipc, epc;
input [15:0] data;
output [15:0] pcout;

reg [15:0] cnt;

assign pcout = cnt;

always @ (posedge clk, negedge reset)
begin
	if(!reset)
	begin
		cnt = 0;
	end
	else
	begin
		if(ipc)
		begin
			if(cnt == 16'b1111111111111111)
			begin
				cnt <= 0;
			end
			else
			begin
				cnt <= cnt + 1;
			end
		end
		else if(epc)
		begin
			cnt <= data;
		end
	end
end


endmodule