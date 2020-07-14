`timescale 10 ns/100 ps
module tb ();

reg clock,
	reset;
	// Observer
wire [15:0] o_data,
	o_cmd,
	o_reg0,
	o_reg1,
	o_sp,
	o_bp,
	o_ip,
	o_mar,
	o_buff_data,
	o_addr;
	

cpu _cpu(
	clock,
	reset,
	// Obersver
	o_data,
	o_cmd,
	o_reg0,
	o_reg1,
	o_sp,
	o_bp,
	o_ip,
	o_mar,
	o_buff_data,
	o_addr
);
	   


initial
begin
    clock = 0;
    reset = 0;
    # 1;
    reset = 1;
end

always
begin
    # 1 clock = ~ clock;
end

endmodule