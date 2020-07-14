`timescale 10 ns/100 ps
module tb ();

reg clock,
	reset;
	// Observer
wire [15:0] o_jp,
	o_ip,
	o_addr,
	o_sp,
	o_cmd,
	o_memory,
	o_ss_data,
	o_reg0,
	o_reg1,
	o_bp,
	o_data_trans;

cpu_w cpu(clock,
	reset,
	// Observer
	o_jp,
	o_ip,
	o_addr,
	o_sp,
	o_cmd,
	o_memory,
	o_ss_data,
	o_reg0,
	o_reg1,
	o_bp,
	o_data_trans);        


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