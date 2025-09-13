



module carHW_Animate_LRoad (traffic_clk, reset, add_car_rand, car_move_array);

	input logic traffic_clk, reset, add_car_rand;
	output logic [13:0] [1:0] car_move_array;
	
	logic add_car;
	logic initalize, add_car_stage1, add_car_stage2, space, shift_all;
	
	enum {INITALIZE, READY, ADD_CAR_S1, ADD_CAR_S2, SPACE} ps, ns;
	
	always_comb begin
		
		case(ps)
		
			 INITALIZE: begin 
								ns = READY;
							end
							
			     READY: begin
								if (add_car_rand) begin
									ns = ADD_CAR_S1;
								end
								else begin
									ns = READY;
								end
							end
		
			ADD_CAR_S1: begin
								ns = ADD_CAR_S2;
							end
							
			ADD_CAR_S2: begin
								ns = SPACE;
							end
							
				  SPACE: begin
								ns = READY;
							end
	
		endcase
	end
	
	assign initalize = (ps == INITALIZE);
	assign add_car_stage1 = (ps == ADD_CAR_S1);
	assign add_car_stage2 = (ps == ADD_CAR_S2);
	assign space = (ps == SPACE);
	assign shift_all = (ps != INITALIZE);
	
	
	
	always_ff @(posedge traffic_clk) begin
		if (reset) begin
			ps <= INITALIZE;
		end
		else begin
			ps <= ns;
		end
	end
	
	always_ff @(posedge traffic_clk) begin
	
		if (initalize) begin
			car_move_array <= 14'b0;
		end
		else if (add_car_stage1) begin
			car_move_array[00] <= 2'b11;
		end
		else if (add_car_stage2) begin
			car_move_array[00] <= 2'b11;
		end
		else if (space) begin
			car_move_array[00] <= 2'b00;
		end
		
		if (shift_all) begin
			car_move_array[01] <= car_move_array[00];
			car_move_array[02] <= car_move_array[01];
			car_move_array[03] <= car_move_array[02];
			car_move_array[04] <= car_move_array[03];
			car_move_array[05] <= car_move_array[04];
			car_move_array[06] <= car_move_array[05];
			car_move_array[07] <= car_move_array[06];
			car_move_array[08] <= car_move_array[07];
			car_move_array[09] <= car_move_array[08];
			car_move_array[10] <= car_move_array[09];
			car_move_array[11] <= car_move_array[10];
			car_move_array[12] <= car_move_array[11];
			car_move_array[13] <= car_move_array[12];
			//car_move_array[14] <= 2'b00;
			//car_move_array[15] <= 2'b00;
		end
	
	end

endmodule



module carHW_Animate_LRoad_tb();

	logic traffic_clk, reset, add_car_rand;
	logic [13:0] [1:0] car_move_array;
	
	carHW_Animate_LRoad dut (traffic_clk, reset, add_car_rand, car_move_array);

	parameter CLOCK_PERIOD = 100;
	
	initial begin
		traffic_clk <= 0;
		forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;
	end

	initial begin
	
		reset <= 1; add_car_rand <= 0; repeat(4)  @(posedge traffic_clk);
		reset <= 0; add_car_rand <= 0; repeat(4)  @(posedge traffic_clk);
		reset <= 0; add_car_rand <= 1;            @(posedge traffic_clk);
		reset <= 0; add_car_rand <= 0; repeat(20) @(posedge traffic_clk);
		reset <= 0; add_car_rand <= 1; repeat(40) @(posedge traffic_clk);
	
		$stop;
	end

endmodule

//
//
//
//module carHW_Animate(traffic_clk, reset, green_move, add_car_rand, car_move_array);
//
//	input logic traffic_clk, reset, green_move, add_car_rand;
//	output logic [15:0] [1:0] car_move_array;
//	
//	logic add_car;
//	logic initalize, add_car_stage1, add_car_stage2, move, shift_all;
//	
//	assign add_car = green_move && add_car_rand;
//	
//	enum {INITALIZE, READY, ADD_CAR_S1, ADD_CAR_S2, MOVE_S1, MOVE_S2, MOVE_S3} ps, ns;
//	
//	always_comb begin
//		
//		case(ps)
//		
//			 INITALIZE: begin 
//								ns = READY;
//							end
//							
//			     READY: begin
//								if (add_car) begin
//									ns = ADD_CAR_S1;
//								end
//								else begin
//									ns = READY;
//								end
//							end
//		
//			ADD_CAR_S1: begin
//								ns = ADD_CAR_S2;
//							end
//							
//			ADD_CAR_S2: begin
//								ns = MOVE_S1;
//							end
//			
//			      MOVE_S1: begin
//								ns = MOVE_S2;
//							end
//							
//					MOVE_S2: begin
//								ns = MOVE_S3;
//							end
//							
//					MOVE_S3: begin
//								ns = READY;
//							end
//	
//		endcase
//	end
//	
//	assign initalize = (ps == INITALIZE);
//	assign add_car_stage1 = (ps == ADD_CAR_S1);
//	assign add_car_stage2 = (ps == ADD_CAR_S2);
//	assign move = (ps == MOVE_S1) || (ps == MOVE_S2) || (ps == MOVE_S3);
//	assign shift_all = (ps != INITALIZE);
//	
//	
//	
//	always_ff @(posedge traffic_clk) begin
//		if (reset) begin
//			ps <= INITALIZE;
//		end
//		else begin
//			ps <= ns;
//		end
//	end
//	
//	always_ff @(posedge traffic_clk) begin
//	
//		if (initalize) begin
//			car_move_array <= 16'b0;
//		end
//		else if (add_car_stage1) begin
//			car_move_array[00] <= 2'b11;
//		end
//		else if (add_car_stage2) begin
//			car_move_array[00] <= 2'b11;
//			car_move_array[01] <= 2'b11;
//		end
//		else if (move) begin
//			car_move_array[00] <= 2'b00;
//			car_move_array[01] <= car_move_array[00];
//			car_move_array[02] <= car_move_array[01];
//		end
//		
//		if (shift_all) begin
//			car_move_array[03] <= car_move_array[02];
//			car_move_array[04] <= car_move_array[03];
//			car_move_array[05] <= car_move_array[04];
//			car_move_array[06] <= car_move_array[05];
//			car_move_array[07] <= car_move_array[06];
//			car_move_array[08] <= car_move_array[07];
//			car_move_array[09] <= car_move_array[08];
//			car_move_array[10] <= car_move_array[09];
//			car_move_array[11] <= car_move_array[10];
//			car_move_array[12] <= car_move_array[11];
//			car_move_array[13] <= car_move_array[12];
//			car_move_array[14] <= 2'b00;
//			car_move_array[15] <= 2'b00;
//		end
//	
//	end
//
//endmodule
