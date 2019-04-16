//`include "vga_adapter/vga_adapter.v"
//`include "vga_adapter/vga_address_translator.v"
//`include "vga_adapter/vga_controller.v"
//`include "vga_adapter/vga_pll.v"

module music_viz2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
      KEY,
      SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [2:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	

	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
//	vga_adapter VGA(
//			.resetn(resetn),
//			.clock(CLOCK_50),
//			.colour(colour_out),
//			.x(x[7:0]),
//			.y(y[7:0]),
//			.plot(writeEn),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "160x120";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//		defparam VGA.BACKGROUND_IMAGE = "black.mif";
//			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

	wire resetn;
	assign resetn = KEY[0];
	
	wire user_visualize;
	assign user_visualize = ~KEY[1];
	
	wire [7:0] start_x; 
	wire [7:0] start_y;
	wire [7:0] end_x;
	wire [7:0] end_y;
	wire [1:0] ring_number;
	wire [3:0] line_number;
	wire load_colour, calc, draw;
	wire writeEn;
	wire [2:0] colour_out;
	wire [7:0] x;
	wire [7:0] y;
	wire busy;
	wire done;
	wire [2:0] colour;

  	wire [5:0] curr_state;
	wire load_black;
	
	assign done = ( (end_x[7:0] == x[7:0]) && (end_y == y[7:0]));
	
	wire done_counting, ready_next_ring;
	//assign done_counting = !KEY[2];	
	//assign ready_next_ring = 1'b1;
	
	wire [1:0] next_ring_num;
	//assign next_ring_num = 2'b10;
	
	
	wire start_counting, find_next_ring_num, screen_has_ring	;
		
	muvi_datapath d0(.start_x(start_x[7:0]), .start_y(start_y[7:0]), .end_x(end_x[7:0]), .end_y(end_y[7:0]), .ring(ring_number[1:0]), .line(line_number[3:0]), .colour_in(colour[2:0]), .colour_out(colour_out[2:0]), .reset(resetn), .calculate(calc), .draw(draw), .load_colour(load_colour), .clock(CLOCK_50), .x(x[7:0]), .y(y[7:0]), .wr(writeEn), .busy(busy));
	
	control c0(.clk(CLOCK_50), 
	.resetn(resetn), 
	.user_visualize(user_visualize), 
	.busy(~done), 
	.colour_in(SW[2:0]), 
	.done_counting(done_counting),
	.ready_next_ring(ready_next_ring),
	.next_ring_num(next_ring_num[1:0]), 
	.current_state(curr_state[5:0]),
	.load_colour(load_colour), 
	.calc(calc),
	.draw(draw), 
	.start_counting(start_counting), 
	.find_next_ring_num(find_next_ring_num),
	.line_number(line_number[3:0]), 
	.ring_number(ring_number[1:0]),
	.colour_out(colour[2:0]),
	.load_black(load_black),
	.screen_has_ring(screen_has_ring));
	
	audio_datapath d1(.start_counting(start_counting), 
	.done_counting(done_counting), 
	.find_next_ring(find_next_ring_num), 
	.ready_next_ring(ready_next_ring), 
	.next_ring_num(next_ring_num[1:0]), 
	.clk(CLOCK_50), 
	.reset(resetn)
	) ;
                  
endmodule        
                
module control(
    input clk,
    input resetn,
    input user_visualize,
	 input busy,
	 input [2:0] colour_in,
	 input done_counting,
	 input ready_next_ring,
	 input [1:0] next_ring_num,
	 output reg [5:0] current_state,
    output reg  load_colour, calc, draw, start_counting, find_next_ring_num,
	 output reg [3:0] line_number,
	 output reg [1:0] ring_number,
	 output reg [2:0] colour_out, 
	 output reg load_black, 
	 output reg screen_has_ring
    );
	 
	 reg  next_visualize;
	 reg [5:0] next_state;
	
	 reg erase;
	 
    localparam  LOAD_INFO = 6'd0,
                DRAW_OR_ERASE = 6'd1,
                CALC_0 = 6'd2,
                DRAW_0 = 6'd3,
                CALC_1 = 6'd4,
                DRAW_1 = 6'd5,
                CALC_2 = 6'd6,
                DRAW_2 = 6'd7,					 
                CALC_3 = 6'd8,
                DRAW_3 = 6'd9,     
                CALC_4 = 6'd10,
                DRAW_4 = 6'd11, 
                CALC_5 = 6'd12,
                DRAW_5 = 6'd13, 		
                CALC_6 = 6'd14,
                DRAW_6 = 6'd15, 
                CALC_7 = 6'd16,
                DRAW_7 = 6'd17, 
                CALC_8 = 6'd18,
                DRAW_8 = 6'd19, 
		          CALC_9 = 6'd20,
                DRAW_9 = 6'd21,
                CALC_10 = 6'd22,
                DRAW_10 = 6'd23, 					
                CALC_11 = 6'd24,
                DRAW_11 = 6'd25, 				
                CALC_12 = 6'd26,
                DRAW_12 = 6'd27, 			
                CALC_13 = 6'd28,
                DRAW_13 = 6'd29, 		
                CALC_14 = 6'd30,
                DRAW_14 = 6'd31,
                CALC_15 = 6'd32,
                DRAW_15 = 6'd33,
					 COUNT_1S = 6'd34,
					 DECIDE_COUNT_OR_FIND_RING = 6'd35,
					 FIND_RING = 6'd36;

			
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                LOAD_INFO: next_state = (user_visualize || next_visualize) ? DRAW_OR_ERASE : LOAD_INFO; // Loop in current state until value is input
                DRAW_OR_ERASE: next_state = (~user_visualize || load_black) ? CALC_0: DRAW_OR_ERASE; // Loop in current state until go signal goes low
                CALC_0: next_state = DRAW_0;
                DRAW_0: next_state = busy ? DRAW_0: CALC_1; 
                CALC_1: next_state = DRAW_1;
                DRAW_1: next_state = busy ? DRAW_1: CALC_2; 					 
                CALC_2: next_state = DRAW_2;
                DRAW_2: next_state = busy ? DRAW_2: CALC_3; 					 
                CALC_3: next_state = DRAW_3;
                DRAW_3: next_state = busy ? DRAW_3: CALC_4; 					 
                CALC_4: next_state = DRAW_4;
                DRAW_4: next_state = busy ? DRAW_4: CALC_5; 					 
                CALC_5: next_state = DRAW_5;
                DRAW_5: next_state = busy ? DRAW_5: CALC_6; 					 
                CALC_6: next_state = DRAW_6;
                DRAW_6: next_state = busy ? DRAW_6: CALC_7; 
                CALC_7: next_state = DRAW_7;
                DRAW_7: next_state = busy ? DRAW_7: CALC_8; 
                CALC_8: next_state = DRAW_8;
                DRAW_8: next_state = busy ? DRAW_8: CALC_9; 
                CALC_9: next_state = DRAW_9;
                DRAW_9: next_state = busy ? DRAW_9: CALC_10; 
                CALC_10: next_state = DRAW_10;
                DRAW_10: next_state = busy ? DRAW_10: CALC_11; 
                CALC_11: next_state = DRAW_11;
                DRAW_11: next_state = busy ? DRAW_11: CALC_12; 
                CALC_12: next_state = DRAW_12;
                DRAW_12: next_state = busy ? DRAW_12: CALC_13; 
                CALC_13: next_state = DRAW_13;
                DRAW_13: next_state = busy ? DRAW_13: CALC_14; 
                CALC_14: next_state = DRAW_14;
                DRAW_14: next_state = busy ? DRAW_14: CALC_15; 
                CALC_15: next_state = DRAW_15;
                DRAW_15: next_state = busy ? DRAW_15: COUNT_1S;
					 COUNT_1S: next_state = done_counting?  DECIDE_COUNT_OR_FIND_RING : COUNT_1S;
					 DECIDE_COUNT_OR_FIND_RING: next_state = screen_has_ring? DRAW_OR_ERASE: FIND_RING;
					 FIND_RING: next_state = ready_next_ring? LOAD_INFO : FIND_RING;
			 
            default:     next_state = LOAD_INFO;
        endcase
    end // state_table
	 	

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        load_colour= 1'b0;
        calc = 1'b0;
        draw = 1'b0;
		  line_number = 4'd0;
		  start_counting <= 1'b0;
		  find_next_ring_num <= 1'b0;
        case (current_state)
				LOAD_INFO: begin
					screen_has_ring <= 1'b1;
					if(user_visualize)
					begin
						ring_number <= 2'b00;
					end
					else if(next_visualize)
					begin
						ring_number <= next_ring_num;
					end
				end		  
				DRAW_OR_ERASE: begin
					load_colour<= 1'b1;
					if (load_black)
					begin
						colour_out <= 3'b000;
						screen_has_ring <= 1'b0;
						next_visualize <= 1'b0;
					end
					else if(erase)
					begin
						colour_out <= 3'b000;
						screen_has_ring <= 1'b0;
					end
					else
					begin
						colour_out <= colour_in;
					end
				end
            CALC_0: begin
                calc = 1'b1;
					 line_number <= 4'b0000;					
            end
            DRAW_0: begin
                draw = 1'b1;
					 line_number <= 4'b0000;
                end
            CALC_1: begin
					 calc = 1'b1;
					 line_number <= 4'b0001;                
					 end
            DRAW_1: begin
                draw = 1'b1;
					 line_number <= 4'b0001;  
                end					 
				CALC_2: begin
                calc = 1'b1;
					 line_number <= 4'b0010;
                end
            DRAW_2: begin
                draw = 1'b1;
					 line_number <= 4'b0010;
                end
            CALC_3: begin
					 calc = 1'b1;
					 line_number <= 4'b0011;                
					 end
            DRAW_3: begin
                draw = 1'b1;
					 line_number <= 4'b0011;
                end
				CALC_4: begin
                calc = 1'b1;
					 line_number <= 4'b0100;
                end
            DRAW_4: begin
                draw = 1'b1;
					 line_number <= 4'b0100;
                end
            CALC_5: begin
					 calc = 1'b1;
					 line_number <= 4'd5;                
					 end
            DRAW_5: begin
                draw = 1'b1;
					 line_number <= 4'd5;
                end					 
				CALC_6: begin
                calc = 1'b1;
					 line_number <= 4'd6;
                end
            DRAW_6: begin
                draw = 1'b1;
					 line_number <= 4'd6;
                end
            CALC_7: begin
					 calc = 1'b1;
					 line_number <= 4'd7;                
					 end
            DRAW_7: begin
                draw = 1'b1;
					 line_number <= 4'd7;
                end					 
				CALC_8: begin
                calc = 1'b1;
					 line_number <= 4'd8;
                end
            DRAW_8: begin
                draw = 1'b1;
					 line_number <= 4'd8;
                end
            CALC_9: begin
					 calc = 1'b1;
					 line_number <= 4'd9;                
					 end
            DRAW_9: begin
                draw = 1'b1;
					 line_number <= 4'd9;
                end					 
				CALC_10: begin
                calc = 1'b1;
					 line_number <= 4'd10;
                end
            DRAW_10: begin
                draw = 1'b1;
					 line_number <= 4'd10;
                end
            CALC_11: begin
					 calc = 1'b1;
					 line_number <= 4'd11;                
					 end
            DRAW_11: begin
                draw = 1'b1;
					 line_number <= 4'd11;
                end					 
				CALC_12: begin
                calc = 1'b1;
					 line_number <= 4'd12;
                end
            DRAW_12: begin
                draw = 1'b1;
					 line_number <= 4'd12;
                end
            CALC_13: begin
					 calc = 1'b1;
					 line_number <= 4'd13;                
					 end
            DRAW_13: begin
                draw = 1'b1;
					 line_number <= 4'd13;
                end					 
				CALC_14: begin
                calc = 1'b1;
					 line_number <= 4'd14;
                end
            DRAW_14: begin
                draw = 1'b1;
					 line_number <= 4'd14;
                end
            CALC_15: begin
					 calc = 1'b1;
					 line_number <= 4'd15;                
					 end
            DRAW_15: begin
                draw = 1'b1;
					 line_number <= 4'd15;
                end
				COUNT_1S: begin
					start_counting <= 1'b1;
				end
				DECIDE_COUNT_OR_FIND_RING: begin
					if(screen_has_ring)
					begin
						erase <= 1'b1;
						next_visualize <= 1'b1;
					end
				
					else
					begin
						find_next_ring_num <= 1'b1;
						erase <= 1'b0;
					end
					
				end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
	wire [3:0] count;
	reg  reset_count;
//	wire reset_count_wire, enable_wire;
//	assign reset_count_wire = reset_count;
//	assign enable_wire = enable;
		
	up_counter c(.out(count[3:0]), .clk(clk), .reset(reset_count));
	 
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
		  begin
            current_state <= DRAW_OR_ERASE;
				reset_count <= 1'b1;
				load_black <= 1'b1;
				// user_visualize is next thus it wont be next_visualize

		  end 
        else if(count[3:0] == 4'b1111)
		  begin
            current_state <= next_state;
				load_black <= 1'b0;
				reset_count <= 1'b1;
		  end 
		  else
		  begin
				reset_count <= 1'b0;
		  end		
    end // state_FFS
endmodule


// asic world
module up_counter    (
	out     ,  // Output of the counter
	clk     ,  // clock Input
	reset      // reset Input
	);
	//----------Output Ports--------------
		 output [3:0] out;
	//------------Input Ports--------------
		  input clk, reset;
	//------------Internal Variables--------
		 reg [3:0] out;
	//-------------Code Starts Here-------
	always @(posedge clk)
	begin
		if (reset) 
		begin
		  out <= 4'b0000;
		end
		else
		begin 
		  out <= out + 1;
		end
	end	

endmodule 


//centre: 80x60
//start radius: 20
//end radius: 40

module muvi_datapath(start_x, 
							start_y, 
							end_x, 
							end_y, 
							ring,  
							line,	
							colour_in, 
							colour_out, 
							reset, 
							calculate, 
							draw, 
							load_colour,
							clock, 
							x,
							y, 
							wr,
							busy
							);
	
	input [2:0] colour_in;
	output reg	[2:0] colour_out;
	input reset;
	input calculate;
	input draw;
	input load_colour;
	input [1:0] ring;
	input [3:0] line;
	output wire [7:0] start_x;
	output wire [7:0] start_y;
	output wire [7:0] end_x;
	output wire [7:0] end_y;
	input clock;
	output [7:0] x;
	output [7:0] y;
	
	output wire busy;
	output wire wr;
	wire [15:0] xy;
	 
	reg [7:0] sx;
	reg [7:0] sy;
	reg [7:0] ex;
	reg [7:0] ey;
	
	get_coord coordinates(.ring(ring[1:0]), .angle(line[3:0]), .start_x(start_x[7:0]), .start_y(start_y[7:0]), .end_x(end_x[7:0]), .end_y(end_y[7:0]));
	
	always @ (posedge clock) 
	begin
        if (!reset) 
				begin
				//get_coord coordinates(.ring(3'd6), .angle(angle), .start_x(start_x[7:0]), .start_y(start_y[7:0]), .end_x(end_x[7:0]), .end_y(end_y[7:0]));
				sx <= 8'b00000000;
				sy <= 8'b00000000;
				ex <= 8'b00000000;
				ey <= 8'b00000000;
				end
		  else if (calculate)
		      begin
			   //get_coord coordinates(.ring(ring), .angle(angle), .start_x(start_x[7:0]), .start_y(start_y[7:0]), .end_x(end_x[7:0]), .end_y(end_y[7:0]));
				sx <= start_x;
				sy <= start_y;
				ex <= end_x;
				ey <= end_y;
				end
		  else if (load_colour)
				begin
				colour_out <= colour_in;
				end
    end
	 
	 linedraw drawline(.go(draw), 
						.busy(busy), 
						.stax(sx[7:0]), 
						.stay(sy[7:0]),
						.endx(ex[7:0]),
						.endy(ey[7:0]),
						.wr(wr), 
						.addr(xy[15:0]),
						.pclk(clock)
						);
	 assign x = xy[7:0];
	 assign y = xy[15:8];
//	 assign colour_out = colour_in;
 
//    always @(*)
//    begin 
//        case (angle)
//            0: begin
//                   start_x = start_rad + 01010000;
//						 start_y = 00111100;
//						 end_x = end_rad + 01010000;
//						 end_y = 00111100; 
//               end
//            1: begin
//                   start_x = $realtobits(start_rad*0.92388 + 80);
//						 start_y = $realtobits(start_rad*0.38268 + 60);
//						 end_x = $realtobits(end_rad*0.92388 + 80);
//						 end_y = $realtobits(end_rad*0.38268 + 60);
//               end
//				2: begin
//                   start_x = $realtobits(start_rad*0.70711 + 80);
//						 start_y = $realtobits(start_rad*0.70711 + 60);
//						 end_x = $realtobits(end_rad*0.70711 + 80);
//						 end_y = $realtobits(end_rad*0.70711 + 60);
//               end	
//            //default: alu_out = 8'd0;
//        endcase
//    end

endmodule 


module get_coord(ring, angle, start_x, start_y, end_x, end_y);

	input [1:0] ring;
	input [3:0] angle;
   output reg [7:0] start_x;
   output reg [7:0] start_y;
	output reg [7:0] end_x;
   output reg [7:0] end_y;
	
	always @(*)
		 begin 
			  case (ring[1:0])
					0: begin
							case (angle[3:0])
								0: begin
									 start_x = 8'b01101110; //110
									 start_y = 8'b00111100; //60
									 end_x = 8'b01111000; //120
									 end_y = 8'b00111100; //60
									end 
								1: begin
									 start_x = 8'b01101100; //108
									 start_y = 8'b01000111; //71
									 end_x = 8'b01110101; //117
									 end_y = 8'b01001011; //75
									end 
								2: begin
									 start_x = 8'b01100101; //101 69 = 0100101
									 start_y = 8'b01010001; //81
									 end_x = 8'b01101100; //108 44 = 00101100 
									 end_y = 8'b01011000; //88 56 = 00111000
									end 
								3: begin
									 start_x = 8'b01011011; //91
									 start_y = 8'b01011000; //88
									 end_x = 8'b01011111; //95
									 end_y = 8'b01100001; //97
									end 
								4: begin
									 start_x = 8'b01010000; //80
									 start_y = 8'b01011010; //90
									 end_x = 8'b01010000; //80
									 end_y = 8'b01100100; //100
									end 
								5: begin
									 start_x = 8'b01000101; //69
									 start_y = 8'b01011000; //88
									 end_x = 8'b01000001; //65
									 end_y = 8'b01100001; //97
									end 
								6: begin
									 start_x = 8'b00111011; //59
									 start_y = 8'b01010001; //81
									 end_x = 8'b00110100; //52
									 end_y = 8'b01011000; //88
									end 
								7: begin
									 start_x = 8'b00110100; //52
									 start_y = 8'b01000111; //71
									 end_x = 8'b00101011; //43
									 end_y = 8'b01001011; //75
									end 
								8: begin
									 start_x = 8'b00110010; //50
									 start_y = 8'b00111100; //60
									 end_x = 8'b00101000; //40
									 end_y = 8'b00111100; //60
									end 
								9: begin
									 start_x = 8'b00110100; //52
									 start_y = 8'b00110001; //49 
									 end_x = 8'b00101011; //43
									 end_y = 8'b00101101; //45
									end
								10: begin
									 start_x = 8'b00111011; //59
									 start_y = 8'b00100111; //39
									 end_x = 8'b00110100; //52
									 end_y = 8'b00100000; //32
									end 
								11: begin
									 start_x = 8'b01000101; //69
									 start_y = 8'b00100000; //32
									 end_x = 8'b01000001; //65
									 end_y = 8'b00010111; //23
									end 
								12: begin
									 start_x = 8'b01010000; //80
									 start_y = 8'b00011110; //30
									 end_x = 8'b01010000; //80
									 end_y = 8'b00010100; //20
									end 
								13: begin
									 start_x = 8'b01011011; //91
									 start_y = 8'b00100000; //32
									 end_x = 8'b01011111; //95
									 end_y = 8'b00010111; //23
									end 
								14: begin
									 start_x = 8'b01100101; //101
									 start_y = 8'b00100111; //39
									 end_x = 8'b01101100; //108
									 end_y = 8'b00100000; //32
									end 
								15: begin
									 start_x = 8'b01101100; //108
									 start_y = 8'b00110001; //49
									 end_x = 8'b01110101; //117
									 end_y = 8'b00101101; //45
									end	
							endcase
						end
					1: begin
							 case (angle[3:0])
								0: begin
									 start_x = 8'b01111000; //120
									 start_y = 8'b00111100; //60
									 end_x = 8'b10000010; //130
									 end_y = 8'b00111100; //60
									end 
								1: begin
									 start_x = 8'b01110101; //117
									 start_y = 8'b01001011; //75
									 end_x = 8'b01111110; //126
									 end_y = 8'b01001111; //79
									end 
								2: begin
									 start_x = 8'b01101100;//108
									 start_y = 8'b01011000; //88
									 end_x = 8'b01110011; //115
									 end_y = 8'b01011111; //95
									end 
								3: begin
									 start_x = 8'b01011111; //95
									 start_y = 8'b01100001; //97
									 end_x = 8'b01100011; //99
									 end_y = 8'b01101010; //106
									end 
								4: begin
									 start_x = 8'b01010000; //80
									 start_y = 8'b01100100; //100
									 end_x = 8'b01010000; //80
									 end_y = 8'b01101110; //110
									end 
								5: begin
									 start_x = 8'b01000001; //65
									 start_y = 8'b01100001; //97
									 end_x = 8'b00111101; //61
									 end_y = 8'b01101010; //106
									end 
								6: begin
									 start_x = 8'b00110100; //52
									 start_y = 8'b01011000; //88
									 end_x = 8'b00101101; //45
									 end_y = 8'b01011111; //95
									end 
								7: begin
									 start_x = 8'b00101011; //43
									 start_y = 8'b01001011; //75
									 end_x = 8'b00100010; //34
									 end_y = 8'b01001111; //79
									end 
								8: begin
									 start_x = 8'b00101000; //40
									 start_y = 8'b00111100; //60
									 end_x = 8'b00011110; //30
									 end_y = 8'b00111100; //60
									end 
								9: begin
									 start_x = 8'b00101011; //43
									 start_y = 8'b00101101; //45
									 end_x = 8'b00100010; //34
									 end_y = 8'b00101001; //41
									end
								10: begin
									 start_x = 8'b00110100; //52
									 start_y = 8'b00100000; //32
									 end_x = 8'b00101101; //45
									 end_y = 8'b00011001; //25
									end 
								11: begin
									 start_x = 8'b01000001; //65
									 start_y = 8'b00010111; //23
									 end_x = 8'b00111101; //61
									 end_y = 8'b00001110; //14
									end 
								12: begin
									 start_x = 8'b01010000; //80
									 start_y = 8'b00010100; //20
									 end_x = 8'b01010000; //80
									 end_y = 8'b00001010; //10
									end 
								13: begin
									 start_x = 8'b01011111; //95
									 start_y = 8'b00010111; //23
									 end_x = 8'b01100011; //99
									 end_y = 8'b00001110; //14
									end 
								14: begin
									 start_x = 8'b01101100; //108
									 start_y = 8'b00100000; //32
									 end_x = 8'b01110011; //115
									 end_y = 8'b00011001; //25
									end 
								15: begin
									 start_x = 8'b01110101; //117
									 start_y = 8'b00101101; //45
									 end_x = 8'b01111110; //126
									 end_y = 8'b00101001; //41
									end
							endcase
						end
					2: begin
							case (angle[3:0])
								0: begin
									start_x = 8'b10000010; //130
									start_y = 8'b00111100; //60
							 		end_x = 8'b10001100; //140
									end_y = 8'b00111100; //60
									end	
								1: begin
									start_x = 8'b01111110; //126
									start_y = 8'b01001111; //79
							 		end_x = 8'b10000111; //135
									end_y = 8'b01010011; //83
									end
								2: begin
									start_x = 8'b01110011; //115
									start_y = 8'b01011111; //95
							 		end_x = 8'b01111010; //122
									end_y = 8'b01100110; //102
									end
								3: begin
									start_x = 8'b01100011; //99
									start_y = 8'b01101010; //106
							 		end_x = 8'b01100111; //103
									end_y = 8'b01110011; //115
									end
								4: begin
									start_x = 8'b01010000; //80
									start_y = 8'b01101110; //110
							 		end_x = 8'b01010000; //80
									end_y = 8'b01111000; //120
									end
								5: begin
									start_x = 8'b00111101; //61
									start_y = 8'b01101010; //106
							 		end_x = 8'b00111001; //57
									end_y = 8'b01110011; //115
									end
								6: begin
									start_x = 8'b00101101; //45
									start_y = 8'b01011111; //95
							 		end_x = 8'b00100110; //38
									end_y = 8'b01100110; //102
									end
								7: begin
									start_x = 8'b00100010; //34
									start_y = 8'b01001111; //79
							 		end_x = 8'b00011001; //25
									end_y = 8'b01010011; //83
									end
								8: begin
									start_x = 8'b00011110; //30
									start_y = 8'b00111100; //60
							 		end_x = 8'b00010100; //20
									end_y = 8'b00111100; //60
									end
								9: begin
									start_x = 8'b00100010; //34
									start_y = 8'b00101001; //41
							 		end_x = 8'b00011001; //25
									end_y = 8'b00100101; //37
									end
								10: begin
									start_x = 8'b00101101; //45
									start_y = 8'b00011001; //25
							 		end_x = 8'b00100110; //38
									end_y = 8'b00010010; //18
									end
								11: begin
									start_x = 8'b00111101; //61
									start_y = 8'b00001110; //14
							 		end_x = 8'b00111001; //57
									end_y = 8'b00000101; //5
									end
								12: begin
									start_x = 8'b01010000; //80
									start_y = 8'b00001010; //10
							 		end_x = 8'b01010000; //80
									end_y = 8'b00000000; //0
									end
								13: begin
									start_x = 8'b01100011; //99
									start_y = 8'b00001110; //14
							 		end_x = 8'b01100111; //103
									end_y = 8'b00000101; //5
									end
								14: begin
									start_x = 8'b01110011; //115
									start_y = 8'b00011001; //25
							 		end_x = 8'b01111010; //122
									end_y = 8'b00010010; //18
									end
								15: begin
									start_x = 8'b01111110; //126
									start_y = 8'b00101001; //41
							 		end_x = 8'b10000111; //135
									end_y = 8'b00100101; //37
									end
							endcase
						end

					default: begin
									start_x = 8'b00000000;
									start_y = 8'b00000000;
									end_x = 8'b00000000;
									end_y = 8'b00000000;
								end
			  endcase
		 end
endmodule  


// File: linedraw.v
// This is the linedraw design for EE178 Lab #6.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module linedraw (
  input wire go,
  output wire busy,
  input wire [7:0] stax,
  input wire [7:0] stay,
  input wire [7:0] endx,
  input wire [7:0] endy,
  output wire wr,
  output wire [15:0] addr,
  input wire pclk
  );

parameter [1:0] IDLE = 2'd0;
parameter [1:0] RUN = 2'd1;
parameter [1:0] DONE = 2'd2;

reg [1:0] state;
reg signed [8:0] err;
reg signed [7:0] x, y;
wire signed [7:0] deltax, deltay, dx, dy, x0, x1, y0, y1, next_x, next_y, xa, ya, xb, yb;
wire signed [8:0] err_next, err1, err2, e2;

wire  in_loop, right, down, complete, e2_lt_dx, e2_gt_dy;

//FSM
always @ (posedge pclk)
begin
  case (state)
    IDLE : if (go)
             state <= RUN;
           else
             state <= IDLE;

    RUN : if (complete)
             state   <= DONE;
          else
             state   <= RUN;

    DONE : if (go)
             state <= RUN;
           else
             state <= IDLE;

    default : state <= IDLE;
  endcase
 end



//Line Drawing Algorithm

//Data Path for dx, dy, right, down
assign x0 =  stax;
assign x1 =  endx;
assign deltax = x1 - x0;
assign right = ~(deltax[7]);
assign dx = (!right) ? (-deltax) : (deltax);

assign y0 = stay;
assign y1 = endy;
assign deltay = y1 - y0;
assign down = ~(deltay[7]);
assign dy = (down) ? (-deltay) : (deltay);

//Data Path for Error

assign e2 = err << 1;
assign e2_gt_dy = (e2 > dy) ? 1 : 0;
assign e2_lt_dx = (e2 < dx) ? 1 : 0;
assign err1 = e2_gt_dy ? (err + dy) : err;
assign err2 = e2_lt_dx ? (err1 + dx) : err1;
assign err_next = (in_loop) ? err2 : (dx + dy);
assign in_loop = (state == RUN);

//Data Path for X and Y
assign next_x = (in_loop) ? xb : x0;
assign xb = e2_gt_dy ? xa : x;
assign xa = right ? (x + 1) : (x - 1);

assign next_y = (in_loop) ? yb : y0;
assign yb = e2_lt_dx ? ya : y;
assign ya = down ? (y + 1) : (y - 1);

assign complete = ( (x == x1) && (y == y1) );

always @(posedge pclk)
 begin
    err <= err_next;
    x <= next_x;
    y <= next_y;
 end

assign busy = in_loop;
assign wr = in_loop;
assign addr = {y,x};

endmodule

module audio_datapath(start_counting, done_counting, find_next_ring, ready_next_ring, next_ring_num, clk, reset) ;
	input start_counting;
	output done_counting;
	input find_next_ring;
	output wire ready_next_ring;
	input clk;
	input reset;
	
	output wire [1:0] next_ring_num;
	wire [31:0] volume;
	wire [8:0] index;
	wire get_add;
	wire change;
	
	RateDivider rate_divider(.clock(clk), 
									.par_load(start_counting), 
									.count(count_now), 
									.done_counting(done_counting)
									) ;
	Counter counter(.done_counting(done_counting), 
						.enable(find_next_ring), 
						.reset(reset), 
						.q(index[8:0])
						) ;
	inst_ROM audio_file(.inst_addr(index[8:0]), 
							.load_inst(done_counting), 
							.inst(volume[31:0])
							);
	avg_to_ring get_ring(.avg(volume[31:0]), 
								.ring_num(next_ring_num[1:0]), 
								.ready_ring(ready_next_ring),
								.get_ring(done_counting),
								.clock(clk)
								) ;
	
	//reg start;
//	wire start_count;
	//assign start_count = start;
//	output reg done;
	//reg find;
//	wire find_ring;
	//assign find_ring = find;
//	output reg found;
	reg count;
//	wire count_now;
	assign count_now = count;
//	reg ring_ready;
//	assign ready_next_ring = ring_ready;
	
	always @ (posedge clk) 
	begin
		  //start <= 1'b0; 	
        if (!reset) 
				begin
				//start <= 1'b0;
				count <= 1'b0;
				//ring_ready <= 1'b0;
				end
		  else if (start_counting)
		      begin
			   //start <= start_counting;
				count <= 1'b1;
				end
//		  else if (find_next_ring)
//				begin
//				find <= find_next_ring;	
//				end
			else if (done_counting)
				begin
				count <= 1'b0;
				//ring_ready <= 1'b1;
				end
//			else if (ready_next_ring)
//				begin
//				
//				end
    end

endmodule

module inst_ROM(input[8:0] inst_addr, input load_inst, output[31:0] inst);
    reg[31:0] ROM[127:0]; //declear the size of the instructin memory which is ready-only so it is a ROM
    
	 initial
	 begin
		$readmemb("con_calma_demo_bin.txt",ROM);
	 end
	 
	 assign inst=(load_inst==1'b1)?ROM[inst_addr]:32'hZZZZZZZZ; //if recieved the load instruction command, get the instructon indexed by the address from pc
endmodule
//Mar. 2. 2019, Y. Zhao, EECS2021, YorkU

module avg_to_ring(avg, ring_num, ready_ring, get_ring, clock) ;
	input [31:0] avg;
	output reg [1:0]ring_num;
	output reg ready_ring;
	input get_ring;
	input clock;
	
	always @(posedge clock)
	begin
		ready_ring <= 1'b0;
		if (get_ring == 1'b1)
			begin
			ring_num <= avg[1:0];
			ready_ring <= 1'b1;
			end
//		begin
//			if (avg <= 32'd13000 )
//				begin
//				ring_num <= 2'b00;
//				ready_ring <= 1'b1;
//				end
//			else if ((avg > 32'd13000) && (avg < 32'd18000))
//				begin
//				ring_num <= 2'b01;
//				ready_ring <= 1'b1;
//				end
//			else 
//				begin
//				ring_num <= 2'b10;
//				ready_ring <= 1'b1;
//				end
//		end
	end

endmodule

module Counter(done_counting, enable, reset, q) ;
	input done_counting;
	input reset;
	input enable;
	
	output reg [8:0] q;

	
	always @(negedge reset, posedge enable)
	begin: enable_signals
		//old_q <= q;
		//changed = 1'b0;
		if (~reset)
			begin
			q <= 0;
			end
		else if (enable)
			//begin
			//if (done_counting == 1'b1)
//				begin
//				if (q == 9'b111111111)
//					q <= 9'b000000000;
//				else 
					begin
					q <= q + 9'b000000001;
					//changed <= 1'b1;
					end
//				end
			//end
	end
	
//	always @(posedge clock)
//	begin
//		if (changed)
//			begin
//				gone_up <= 1'b1;
//			end
//		else
//			begin
//				gone_up <= 1'b0;
//			end
//	end
	
endmodule

module RateDivider(clock, par_load, count, done_counting) ;
	input clock;
	input par_load;
	input count;
	
	reg [27:0] c;
	output reg done_counting;
	
	always @(posedge clock)
	begin
	
//		if (par_load == 1'b1)
//			begin
			c <= 28'd49;
			done_counting <= 1'b0;
//			end 
		if (count == 1'b1)
			begin 
				c <= c - 28'd1;
				done_counting <= 1'b0;
				if (c == 28'd0) 
					begin
					c <= 28'd49;
					done_counting <= 1'b1;
					end
				
			end
	end
endmodule
