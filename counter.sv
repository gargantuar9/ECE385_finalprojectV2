
module counter(
					input sample_adjust_clk,
					input treb_en,
					input doublebass_en,
					input bass_en,
					input [9:0] max_count,
					output [9:0] addr_counter
				  );
	
	logic down;
	
	always_ff @ (posedge sample_adjust_clk)
	begin
		
		/*
		if(addr_counter == max_count)
		begin
			addr_counter <= 0;
		end
		*/
		
		logic [1:0] double_check;
		
		
		//If want to get an octave lower to play simultaneously with current pitch,
		//must change address_counter to be double the length of the period of the pitch
		
		//Requires having pitches of different length
		
		if(treb_en)
		begin
			if(addr_counter == ((max_count+1)/2 - 1))
			begin
				addr_counter <= 0;
			end
			else
			begin
				addr_counter <= addr_counter+1;
			end
		end
		
		else if(doublebass_en)
		begin
			if(double_check[1])
			begin
				if(addr_counter == (max_count*2 + 1))
				begin
					addr_counter <= 0;
					double_check <= double_check + 1;
				end
				else
				begin
					addr_counter <= addr_counter + 1;
				end
			end
			
			else
			begin
				if(addr_counter == 0)
				begin
					addr_counter <= addr_counter + max_count + 1;
				end
				else if(addr_counter == ((max_count+1)*5 - 2)) //-1 again for overcount
				begin
					addr_counter <= 0;
					double_check <= 0;
				end
				else
				begin
					addr_counter <= addr_counter + 1;
				end
			end
		end
		

		else if(bass_en)
		begin
			if(addr_counter == (max_count*2 + 1))
			begin
				addr_counter <= 0;
			end
			else
			begin
				addr_counter <= addr_counter+1;
			end
		end
		
		
		else
		begin
			if(addr_counter == max_count)
			begin
				addr_counter <= 0;
			end
			else
			begin
				addr_counter <= addr_counter+1;
			end
		end
		
		/*
		else
		begin
			addr_counter <= addr_counter+1;
		end
		*/
	end

endmodule
