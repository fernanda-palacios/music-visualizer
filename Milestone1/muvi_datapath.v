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
							busy);
	
	input [2:0] colour_in;
	output reg	[2:0] colour_out;
	input reset;
	input calculate;
	input draw;
	input load_colour;
	input ring;
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
	
	get_coord coordinates(.ring(ring), .angle(line[3:0]), .start_x(start_x[7:0]), .start_y(start_y[7:0]), .end_x(end_x[7:0]), .end_y(end_y[7:0]));
	
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

	input ring;
	input [3:0] angle;
   output reg [7:0] start_x;
   output reg [7:0] start_y;
	output reg [7:0] end_x;
   output reg [7:0] end_y;
	
	always @(*)
		 begin 
			  case (ring)
					0: begin
							case (angle)
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
//					1: begin
//							 case (angle)
//								0: begin
//									 start_x = 8'b01111000; //120
//									 start_y = 8'b00111100; //60
//									 end_x = 8'b10000010; //130
//									 end_y = 8'b00111100; //60
//									end 
//								1: begin
//									 start_x = 8'b01110101;/117
//									 start_y = 8'b01001011; //75
//									 end_x = 8'b01111110; //126
//									 end_y = 8'b01001111; //79
//									end 
//								2: begin
//									 start_x = 8'b01101100;//108
//									 start_y = 8'b01011000; //88
//									 end_x = 8'b01110011; //115
//									 end_y = 8'b01011111; //95
//									end 
//								3: begin
//									 start_x = 8'b01011111; //95
//									 start_y = 8'b01100001; //97
//									 end_x = 8'b01100011; //99
//									 end_y = 8'b01101010; //106
//									end 
//								4: begin
//									 start_x = 8'b01010000; //80
//									 start_y = 8'b01100100; //100
//									 end_x = 8'b01010000; //80
//									 end_y = 8'b01101110; //110
//									end 
//								5: begin
//									 start_x = 8'b01000001; //65
//									 start_y = 8'b01100001; //97
//									 end_x = 8'b00111101; //61
//									 end_y = 8'b01101010; //106
//									end 
//								6: begin
//									 start_x = 8'b00110100; //52
//									 start_y = 8'b01011000; //88
//									 end_x = 8'b00101101; //45
//									 end_y = 8'b01011111; //95
//									end 
//								7: begin
//									 start_x = 8'b00101011; //43
//									 start_y = 8'b01001011; //75
//									 end_x = 8'b00100010; //34
//									 end_y = 8'b01001111; //79
//									end 
//								8: begin
//									 start_x = 8'b00101000; //40
//									 start_y = 8'b00111100; //60
//									 end_x = 8'b00011110; //30
//									 end_y = 8'b00111100; //60
//									end 
//								9: begin
//									 start_x = 8'b00101011; //43
//									 start_y = 8'b00101101; //45
//									 end_x = 8'b00100010; //34
//									 end_y = 8'b00101001; //41
//									end
//								10: begin
//									 start_x = 8'b00110100; //52
//									 start_y = 8'b00100000; //32
//									 end_x = 8'b00101101; //45
//									 end_y = 8'b00011001; //25
//									end 
//								11: begin
//									 start_x = 8'b01000001; //65
//									 start_y = 8'b00010111; //23
//									 end_x = 8'b00111101; //61
//									 end_y = 8'b00001110; //14
//									end 
//								12: begin
//									 start_x = 8'b01010000; //80
//									 start_y = 8'b00010100; //20
//									 end_x = 8'b01010000; //80
//									 end_y = 8'b00001010; //10
//									end 
//								13: begin
//									 start_x = 8'b01011111; //95
//									 start_y = 8'b00010111; //23
//									 end_x = 8'b01100011; //99
//									 end_y = 8'b00001110; //14
//									end 
//								14: begin
//									 start_x = 8'b01101100; //108
//									 start_y = 8'b00100000; //32
//									 end_x = 8'b01110011; //115
//									 end_y = 8'b00011001; //25
//									end 
//								15: begin
//									 start_x = 8'b01110101; //117
//									 start_y = 8'b00101101; //45
//									 end_x = 8'b01111110; //126
//									 end_y = 8'b00101001; //41
//									end
//						end
//					2: begin
//							 start_x = $realtobits(start_rad*0.70711 + 80);
//							 start_y = $realtobits(start_rad*0.70711 + 60);
//							 end_x = $realtobits(end_rad*0.70711 + 80);
//							 end_y = $realtobits(end_rad*0.70711 + 60);
//						end
//					3:
//					4:	
					default: begin
									start_x = 8'b00000000;
									start_y = 8'b00000000;
									end_x = 8'b00000000;
									end_y = 8'b00000000;
								end
			  endcase
		 end
endmodule 