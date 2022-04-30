//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------

//Keyboard keycode macros in decimal
`define A 4
`define C 6
`define E 8
`define A5 34

//Number of samples for each note
`define A4max 49
`define C5max 41
`define E5max 32
`define A5max 24


module finalproject (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	logic [7:0] Red, Blue, Green;
	logic [31:0] keycode;
	
	//Final Project Declarations:
	logic i2c0_sda_in, i2c0_scl_in, i2c0_sda_oe, i2c0_scl_oe;
	logic [1:0] aud_mclk_ctr;
	
	logic sclk, lrclk, i2s_Dout;
	logic i2s_Dout_left, i2s_Dout_right;
	logic [31:0] i2s_Din;
	
	logic [9:0] address_counter;
	logic [9:0] sram_out;
	
	logic [7:0] a440, e5, c5, a5;
	logic [9:0] a4counter, c5counter, e5counter, a5counter;
	
	logic bass_enable;
	

//=======================================================
//  Structural coding
//=======================================================
	//Final Project Structure:
	
	//Create 12.5 MHz clock using main clock
	assign ARDUINO_IO[3] = aud_mclk_ctr[1];
	//generate 12.5MHz CODEC mclk
	always_ff @(posedge MAX10_CLK1_50) begin
		aud_mclk_ctr <= aud_mclk_ctr + 1;
	end
	
	//I2C Connections:
	assign i2c0_scl_in = ARDUINO_IO[15];
	assign ARDUINO_IO[15] = i2c0_scl_oe ? 1'b0 : 1'bz;
	assign i2c0_sda_in = ARDUINO_IO[14];
	assign ARDUINO_IO[14] = i2c0_sda_oe ? 1'b0 : 1'bz;
	
	/*
	//Connect Line-In to Line-Out (delete later when create I2S)
	assign ARDUINO_IO[2] = ARDUINO_IO[1];
	assign ARDUINO_IO[1] = 1'bz;
	*/
	assign ARDUINO_IO[2] = ARDUINO_IO[1];
	
	//Assign I2S signals to corresponding Arduinos
	assign sclk = ARDUINO_IO[5];
	assign lrclk = ARDUINO_IO[4];
	
	
	
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
//	//HEX drivers to convert numbers to HEX output
//	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
//	assign HEX4[7] = 1'b1;
//	
//	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
//	assign HEX3[7] = 1'b1;
//	
//	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
//	assign HEX1[7] = 1'b1;
//	
//	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
//	assign HEX0[7] = 1'b1;
//	
//	//fill in the hundreds digit as well as the negative sign
//	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
//	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};

HexDriver display[5:0] (.In(keycode[23:0]), .Out({HEX5, HEX4, HEX3, HEX2, HEX1, HEX0}));
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	
	finalproject_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		
		
		//FINAL PROJECT CHANGES
		//I2C
		.i2c0_sda_in(i2c0_sda_in),
		.i2c0_scl_in(i2c0_scl_in),
		.i2c0_sda_oe(i2c0_sda_oe),
		.i2c0_scl_oe(i2c0_scl_oe)
		
		
	 );
	 
	 
	 //Sample twice as slow
	 logic half_counter = 0;
	 always_ff @(posedge lrclk) begin
		half_counter <= half_counter+1;
	 end
	 //Sample clock four times as slow
	 logic [1:0] quarter_counter = 0;
	 always_ff @(posedge lrclk) begin
		quarter_counter <= quarter_counter+1;
	 end
	 
	 logic chosen_clk;
	 
	 always_comb
	 begin
		if(SW[0])
			bass_enable = 1;
		else
			bass_enable = 0;
			
		if(SW[1])
			doublebass_enable = 1;
		else
			doublebass_enable = 0;
			
		if(SW[2])
			treb_enable = 1;
		else
			treb_enable = 0;
			
			
		unique case (SW[9:8])
			2'b01:	chosen_clk = lrclk;
			2'b10:	chosen_clk = quarter_counter[1];
			default: chosen_clk = half_counter;
		endcase
	 end
	 
	 //Trying to make smoother wave by setting a maximum for address_counter
	 counter A4counter(.sample_adjust_clk(chosen_clk), .treb_en(treb_enable), .doublebass_en(doublebass_enable), .bass_en(bass_enable), .max_count(`A4max), .addr_counter(a4counter));
	 counter C5counter(.sample_adjust_clk(chosen_clk), .treb_en(treb_enable), .doublebass_en(doublebass_enable), .bass_en(bass_enable), .max_count(`C5max), .addr_counter(c5counter));
	 counter E5counter(.sample_adjust_clk(chosen_clk), .treb_en(treb_enable), .doublebass_en(doublebass_enable), .bass_en(bass_enable), .max_count(`E5max), .addr_counter(e5counter));
	 counter A5counter(.sample_adjust_clk(chosen_clk), .treb_en(treb_enable), .doublebass_en(doublebass_enable), .bass_en(bass_enable), .max_count(`A5max), .addr_counter(a5counter));
	 
	 
	 /*
	 always_ff @ (posedge lrclk)
	 begin
		case (keycode[7:0])
			`A: begin
					max_count0 <= 49;
					key
				 end
			max_count0 <= 49; //one less than number of samples (0-indexed)
			`C: max_count0 <= 589;
			`E: max_count0 <= 233;
			`A5: max_count0 <= 24;
		endcase
		
		case (keycode[15:7])
			`A: max_count1 <= 49; //one less than number of samples (0-indexed)
			`C: max_count1 <= 589;
			`E: max_count1 <= 233;
			`A5: max_count1 <= 24;
		endcase
		
		case (keycode[23:16])
			`A: max_count2 <= 49; //one less than number of samples (0-indexed)
			`C: max_count2 <= 589;
			`E: max_count2 <= 233;
			`A5: max_count2 <= 24;
		endcase
		
		case (keycode[31:24])
			`A: max_count3 <= 49; //one less than number of samples (0-indexed)
			`C: max_count3 <= 589;
			`E: max_count3 <= 233;
			`A5: max_count3 <= 24;
		endcase
	 end
	 
	 always_comb
	 begin
		unique case (key0)
			`A: countA4 = max_count
		
		endcase
	 end
	 */
	 
	 
	 counter test(.sample_adjust_clk(half_counter), .max_count(49), .addr_counter(address_counter));
	 
	 /*
	 always_ff @ (posedge half_counter)
	 begin
		
		//if(address_counter == 999)
		if(address_counter == max_count)
		begin
			address_counter <= 0;
		end
		
		
		//If want to get an octave lower to play simultaneously with current pitch,
		//must change address_counter to be double the length of the period of the pitch
		
		//Requires having pitches of different length
		
		else
		begin
			address_counter <= address_counter+1;
		end
	 end
	 */
	 
	 
	 
	 a440RAM ramA4(
					 .read_address(a4counter/*address_counter*/),
					 .Clk(MAX10_CLK1_50),
					 .data_Out(a440)
					);
	 e5RAM ramE5(
					 .read_address(/*address_counter*/e5counter),
					 .Clk(MAX10_CLK1_50),
					 .data_Out(e5)
					);
	 c5RAM ramc5(
					 .read_address(/*address_counter*/c5counter),
					 .Clk(MAX10_CLK1_50),
					 .data_Out(c5)
					);
	 a5RAM ramA5(
					 .read_address(/*address_counter*/a5counter),
					 .Clk(MAX10_CLK1_50),
					 .data_Out(a5)
					);
					
	 /*
	 always_ff
	 begin
		unique case (SW)
			10'b0000000001:	sram_out = a440;
			10'b0000000010:	sram_out = e5;
			10'b0000000100:	sram_out = c5;
			10'b0000000011:	sram_out = a440 + e5;
			10'b0000000101:	sram_out = c5 + a440;
			10'b0000000110:	sram_out = c5 + e5;
			10'b0000000111:	sram_out = a440 + c5 + e5;
			
			//Not coded yet
			10'b0000001000:
			10'b0000010000:
			10'b0000100000:
			10'b0001000000:
			10'b0010000000:
			10'b0100000000:
			10'b1000000000:
			
			default: sram_out = 10'h000;
		endcase
	 end
	 */
	 
	 
	 //Read from keyboard
	 always_ff @ (posedge lrclk)
	 begin
		case (keycode[31:24])
			`A: sram_out = a440;
			`C: sram_out = c5;
			`E: sram_out = e5;
			`A5: sram_out = a5;
			default: sram_out = 10'b0000000000;
		endcase
		case (keycode[23:16])
			`A: sram_out += a440;
			`C: sram_out += c5;
			`E: sram_out += e5;
			`A5: sram_out += a5;
			default: sram_out += 10'b0000000000;
			/*
			`A: sram_out <= sram_out + a440;
			`C: sram_out <= sram_out + c5;
			`E: sram_out <= sram_out + e5;
			`A5: sram_out <= sram_out + a5;
			default: sram_out <= sram_out + 10'b0000000000;
			*/
		endcase
		case (keycode[15:8])
			`A: sram_out += a440;
			`C: sram_out += c5;
			`E: sram_out += e5;
			`A5: sram_out += a5;
			default: sram_out += 10'b0000000000;
			/*
			`A: sram_out <= sram_out + a440;
			`C: sram_out <= sram_out + c5;
			`E: sram_out <= sram_out + e5;
			`A5: sram_out <= sram_out + a5;
			default: sram_out <= sram_out + 10'b0000000000;
			*/
		endcase
		case (keycode[7:0])
			`A: sram_out += a440;
			`C: sram_out += c5;
			`E: sram_out += e5;
			`A5: sram_out += a5;
			default: sram_out += 10'b0000000000;
			/*
			`A: sram_out <= sram_out + a440;
			`C: sram_out <= sram_out + c5;
			`E: sram_out <= sram_out + e5;
			`A5: sram_out <= sram_out + a5;
			default: sram_out <= sram_out + 10'b0000000000;
			*/
		endcase
		
	 end
	
	
	
					
	 assign i2s_Din = {1'b0, //dummy bit
							 //2'b00, //volume control
							 // ^^^ not needed anymore because sram_out is 10 bits (hold 4 notes simultaneously)
							 sram_out,
							 14'h0000, //should be zeroes
							 7'h00 //junk bits
							};
	 
	 shift_register left(.Clk(sclk),
								.lrclk(lrclk),
								.data_in(i2s_Din),
								.data_out(i2s_Dout_left)
							  );
							  
	 shift_register right(.Clk(sclk),
								 .lrclk(~lrclk),
								 .data_in(i2s_Din),
								 .data_out(i2s_Dout_right)
							   );
								
	 always_comb
	 begin
		unique case (lrclk)
			1'b0: i2s_Dout = i2s_Dout_left;
			1'b1: i2s_Dout = i2s_Dout_right;
		endcase
	 end
	 
	 
			  
	 assign ARDUINO_IO[1] = i2s_Dout;

	 
	 
	 
	 
	 

//instantiate a vga_controller, ball, and color_mapper here with the ports.


vga_controller VGA(.Clk(MAX10_CLK1_50),
						 .Reset(Reset_h),
						 .hs(VGA_HS),
						 .vs(VGA_VS),
						 .pixel_clk(VGA_Clk),
						 .blank(blank),
						 .sync(sync),
						 
						 .DrawX(drawxsig),
						 .DrawY(drawysig),
						);


ball Ball(.Reset(Reset_h),
			 .frame_clk(VGA_VS),
			 .keycode(keycode),
			 .BallX(ballxsig),
			 .BallY(ballysig),
			 .BallS(ballsizesig)
			);
			
			
color_mapper(.BallX(ballxsig),
				 .BallY(ballysig),
				 .DrawX(drawxsig),
				 .DrawY(drawysig),
				 .Ball_size(ballsizesig),
				 .Red(Red),
				 .Green(Green),
				 .Blue(Blue),
				);


endmodule
