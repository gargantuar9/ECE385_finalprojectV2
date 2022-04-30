
module shift_register(
							 input logic Clk,
							 input logic lrclk,
							 input logic [31:0] data_in,
							 output logic data_out
							);
							
	logic [31:0] data;
							
	always_ff @ (posedge Clk)
	begin
	
		if(lrclk)
		begin
			data <= data_in;
		end
		else begin
			data <= {data[30:0], 1'b0};
			data_out <= data[31];
		end	
	end
	
endmodule
