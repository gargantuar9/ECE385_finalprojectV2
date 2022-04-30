
module I2S(
			  input SCLK,
			  input LRCLK,
			  input [31:0] I2S_Din,
			  output I2S_Dout
			 );
			 
			 
	logic [31:0] left_data;
	logic [31:0] right_data;
	
	
	always_ff @ (posedge SCLK)
	begin
		
		if(LRCLK) //enter left_data and dump right_data
		begin
			left_data <= I2S_Din;
			
			I2S_Dout <= right_data[31];
			right_data <= {right_data[30:0], 1'bx};
		end
		
		else //enter right_data and dump left_data
		begin
			right_data <= I2S_Din;
			
			I2S_Dout <= left_data[31];
			left_data <= {left_data[30:0], 1'bx};
		end
		
	end

endmodule