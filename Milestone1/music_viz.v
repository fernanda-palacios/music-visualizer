`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"

module music_viz
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
	input   [1:0]   KEY;

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
	
	wire resetn;
	assign resetn = KEY[0];
	
	wire visualize;
	assign visualize = ~KEY[1];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour_out),
			.x(x[7:0]),
			.y(y[7:0]),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

	wire [7:0] start_x; 
	wire [7:0] start_y;
	wire [7:0] end_x;
	wire [7:0] end_y;
	wire ring_number;
	wire [3:0] line_number;
	wire load_colour, calc, draw;
	wire writeEn;
	wire [2:0] colour_out;
	wire [7:0] x;
	wire [7:0] y;
	wire busy;

  	
	muvi_datapath d0(.start_x(start_x[7:0]), .start_y(start_y[7:0]), .end_x(end_x[7:0]), .ring(ring_number), .line(line_number[3:0]), .colour_in(SW[2:0]), .colour_out(colour_out[2:0]), .reset(resetn), .calculate(calc), .draw(draw), .load_colour(load_colour), .clock(CLOCK_50), .x(x[7:0]), .y(y[7:0]), .wr(writeEn), .busy(busy));
	control c0(.clk(CLOCK_50), .resetn(resetn), .visualize(visualize), .load_colour(load_colour), .calc(calc), .draw(draw), .ring_number(ring_number), .line_number(line_number[3:0]), .busy(busy), .line_num(SW[9:6]));
                  
endmodule        
                

module control(
    input clk,
    input resetn,
    input visualize,
	 input busy,
    output reg  load_colour, calc, draw,  ring_number,
	 output reg [3:0] line_number, 
	 input [3:0] line_num
    );
	 
    reg [5:0] current_state, next_state;

    localparam  LOAD_COLOUR = 6'd0,
                LOAD_COLOUR_WAIT = 6'd1,
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
                DRAW_15 = 6'd33; 			

			
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                LOAD_COLOUR: next_state = visualize ? LOAD_COLOUR_WAIT : LOAD_COLOUR; // Loop in current state until value is input
                LOAD_COLOUR_WAIT: next_state = visualize ? LOAD_COLOUR_WAIT : CALC_0; // Loop in current state until go signal goes low
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
                DRAW_15: next_state = busy ? DRAW_15: LOAD_COLOUR; 
			 
            default:     next_state = LOAD_COLOUR;
        endcase
    end // state_table
	 	

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        load_colour = 1'b0;
        calc = 1'b0;
        draw = 1'b0;
        line_number = line_num[3:0];
        ring_number = 1'b0;

        case (current_state)
            LOAD_COLOUR: begin
                load_colour = 1'b1;
                end
            CALC_0: begin
                calc = 1'b1;
//					 line_number = 4'd0;
                end
            DRAW_0: begin
                draw = 1'b1;
//					 line_number = 4'd0;
                end
            CALC_1: begin
					 calc = 1'b1;
//					 line_number = 4'd1;                
					 end
            DRAW_1: begin
                draw = 1'b1;
//					 line_number = 4'd1;  
                end					 
				CALC_2: begin
                calc = 1'b1;
//					 line_number = 4'd2;
                end
            DRAW_2: begin
                draw = 1'b1;
//					 line_number = 4'd2;
                end
            CALC_3: begin
					 calc = 1'b1;
//					 line_number = 4'd3;                
					 end
            DRAW_3: begin
                draw = 1'b1;
//					 line_number = 4'd3;
                end
				CALC_4: begin
                calc = 1'b1;
//					 line_number = 4'd4;
                end
            DRAW_4: begin
                draw = 1'b1;
//					 line_number = 4'd4;
                end
            CALC_5: begin
					 calc = 1'b1;
//					 line_number = 4'd5;                
					 end
            DRAW_5: begin
                draw = 1'b1;
//					 line_number = 4'd5;
                end					 
				CALC_6: begin
                calc = 1'b1;
//					 line_number = 4'd6;
                end
            DRAW_6: begin
                draw = 1'b1;
//					 line_number = 4'd6;
                end
            CALC_7: begin
					 calc = 1'b1;
//					 line_number = 4'd7;                
					 end
            DRAW_7: begin
                draw = 1'b1;
//					 line_number = 4'd7;
                end					 
				CALC_8: begin
                calc = 1'b1;
//					 line_number = 4'd8;
                end
            DRAW_8: begin
                draw = 1'b1;
//					 line_number = 4'd8;
                end
            CALC_9: begin
					 calc = 1'b1;
//					 line_number = 4'd9;                
					 end
            DRAW_9: begin
                draw = 1'b1;
//					 line_number = 4'd9;
                end					 
				CALC_10: begin
                calc = 1'b1;
//					 line_number = 4'd10;
                end
            DRAW_10: begin
                draw = 1'b1;
//					 line_number = 4'd10;
                end
            CALC_11: begin
					 calc = 1'b1;
//					 line_number = 4'd11;                
					 end
            DRAW_11: begin
                draw = 1'b1;
//					 line_number = 4'd11;
                end					 
				CALC_12: begin
                calc = 1'b1;
//					 line_number = 4'd12;
                end
            DRAW_12: begin
                draw = 1'b1;
//					 line_number = 4'd12;
                end
            CALC_13: begin
					 calc = 1'b1;
//					 line_number = 4'd13;                
					 end
            DRAW_13: begin
                draw = 1'b1;
//					 line_number = 4'd13;
                end					 
				CALC_14: begin
                calc = 1'b1;
//					 line_number = 4'd14;
                end
            DRAW_14: begin
                draw = 1'b1;
//					 line_number = 4'd14;
                end
            CALC_15: begin
					 calc = 1'b1;
//					 line_number = 4'd15;                
					 end
            DRAW_15: begin
                draw = 1'b1;
//					 line_number = 4'd15;
                end					 					 
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= LOAD_COLOUR;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
