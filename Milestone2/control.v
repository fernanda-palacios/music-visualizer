module control(
    input clk,
    input resetn,
    input visualize,
	 input busy,
	 input [2:0] colour_in,
	 input done_counting,
	 output reg [5:0] current_state,
    output reg  load_colour, calc, draw,  ring_number,
	 output reg [3:0] line_number,
	 output reg [2:0] colour_out, 
	 output reg load_black
    );
	 
	 reg screen_has_ring;
	 reg [5:0] next_state;
	 
	 wire erased;
	 assign erased = 1'b1;
	 
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
                DRAW_15 = 6'd33,
					 COUNT_1S = 6'd34;

			
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                LOAD_COLOUR: next_state = (visualize || erased) ? LOAD_COLOUR_WAIT : LOAD_COLOUR; // Loop in current state until value is input
                LOAD_COLOUR_WAIT: next_state = (~visualize || load_black) ? CALC_0: LOAD_COLOUR_WAIT; // Loop in current state until go signal goes low
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
                DRAW_15: next_state = !busy & screen_has_ring? COUNT_1S: DRAW_15; 
					 COUNT_1S: next_state = done_counting?  LOAD_COLOUR : COUNT_1S;
			 
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
		  line_number = 4'd0;
        ring_number = 1'b0;

        case (current_state)
				LOAD_COLOUR: begin
					screen_has_ring <= 1'b0;
				end		  
				LOAD_COLOUR_WAIT: begin
					load_colour <= 1'b1;
					if (load_black == 1'b1)
					begin
						colour_out <= 3'b000;
					end
					else
					begin
						colour_out <= colour_in;
					end
				end
            CALC_0: begin
                calc = 1'b1;
					 line_number <= 4'b0000;					screen_has_ring <= 1'b0';
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
					 screen_has_ring <= 1'b1;
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
            current_state <= LOAD_COLOUR_WAIT;
				reset_count <= 1'b1;
				load_black <= 1'b1;
		  end 
        else if(count[3:0] == 4'b1001)
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


