

// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// DISCRPTION: DISPLAYS THE CAR LANE QUEUE COUNTER VALUES, AND THE NUMBER OF COLLISIONS	

module LED_Traffic_Light(clk_traffic, reset, traffic_Level_SWs_i, add_car_to_FR_TRoad_RLane_i, add_car_to_FR_BRoad_RLane_i,
                         add_car_to_FR_BRoad_LLane_Turn_i, add_car_to_FR_TRoad_LLane_Turn_i, 
                         highW_G_farm_R_i, highW_Y_farm_R_i, highW_R_farm_G_i, highW_R_farm_Y_i, 
								 RedPixels, GrnPixels, car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_BRoad_RLane,
								 car_queue_counter_FR_TRoad_LLane, car_queue_counter_FR_BRoad_LLane,
								 master_Collision_Counter);
	
	input logic clk_traffic, reset, highW_G_farm_R_i, highW_Y_farm_R_i, highW_R_farm_G_i, highW_R_farm_Y_i, add_car_to_FR_TRoad_RLane_i, 
	            add_car_to_FR_BRoad_RLane_i, add_car_to_FR_BRoad_LLane_Turn_i, add_car_to_FR_TRoad_LLane_Turn_i;
	input logic [4:0] traffic_Level_SWs_i;
   output logic [15:0][15:0] RedPixels; // 16x16 array of red LEDs
   output logic [15:0][15:0] GrnPixels; // 16x16 array of green LEDs
	output logic [3:0] car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_BRoad_RLane, 
	                   car_queue_counter_FR_TRoad_LLane, car_queue_counter_FR_BRoad_LLane;						 
	output logic [3:0] master_Collision_Counter;
	
	// SIGNALS FOR ADDING A CAR TO A SPECIFIC LANE
	logic add_car_LRoad_LLane, add_car_LRoad_RLane;
	logic add_car_RRoad_LLane, add_car_RRoad_RLane;
	logic add_car_animate_FR_TRoad_RLane;
	logic add_car_animate_FR_BRoad_RLane;
	logic add_car_animate_FR_TRoad_LLane, add_car_animate_FR_TRoad_LLane_From_Add_Module;
	logic add_car_animate_FR_BRoad_LLane, add_car_animate_FR_BRoad_LLane_From_Add_Module;
	
	// LOGIC TO DETERMINE WHNE TO ADD A CAR TO THE LEFT TURNING LANES
	assign add_car_animate_FR_TRoad_LLane = add_car_animate_FR_TRoad_LLane_From_Add_Module && (car_queue_counter_FR_BRoad_RLane == 0);
	assign add_car_animate_FR_BRoad_LLane = add_car_animate_FR_BRoad_LLane_From_Add_Module && (car_queue_counter_FR_TRoad_RLane == 0);
	
	// DECREMENT CAR QUEUE COUNTER SIGNALS
	logic dec_car_in_FR_TRoad_RLane, dec_car_in_FR_TRoad_LLane;
	logic dec_car_in_FR_BRoad_RLane, dec_car_in_FR_BRoad_LLane;
	
	// ARRAYS TO ANIMATE THE CAR MOVMENTS
	logic [13:0] [1:0] car_move_array_HW_LRoad_LLane;
	logic [13:0] [1:0] car_move_array_HW_LRoad_RLane;
	logic [13:0] [1:0] car_move_array_HW_RRoad_LLane;
	logic [13:0] [1:0] car_move_array_HW_RRoad_RLane;
	logic [1:0] [13:0] car_move_array_FR_TRoad_RLane;
	logic [1:0] [13:0] car_move_array_FR_BRoad_RLane;
	logic [1:0] [10:0] car_move_array_FR_TRoad_LLane_H;
	logic [1:0] [10:0] car_move_array_FR_BRoad_LLane_H;
	logic [7:0] [1:0] car_move_array_FR_TRoad_LLane_V;
	logic [6:0] [1:0] car_move_array_FR_BRoad_LLane_V;
	
	// SIGNALS TO ALLOW A TURNING CAR PASS OR ASSERT A CRASH
	logic show_Pass_Top_Turn_Car_RLane_Crash, show_Crash_Top_Turn_Car_RLane_Crash;
	logic show_Pass_Top_Turn_Car_LLane_Crash, show_Crash_Top_Turn_Car_LLane_Crash;
	logic show_Pass_Bott_Turn_Car_RLane_Crash, show_Crash_Bott_Turn_Car_RLane_Crash; 
	logic show_Pass_Bott_Turn_Car_LLane_Crash, show_Crash_Bott_Turn_Car_LLane_Crash;
	
	// COUNTERS TO KEEP TRACK OF THE COLLISIONS
	logic [3:0] collision_Counter_Top_Turn_Car_RLane_Crash, collision_Counter_Top_Turn_Car_LLane_Crash;
	logic [3:0] collision_Counter_Bot_Turn_Car_RLane_Crash, collision_Counter_Bot_Turn_Car_LLane_Crash;
	
	// COLLISION CASE SIGNALS
	logic FR_Top_To_Bott_RLane_Collosion_Case1, FR_Top_To_Bott_RLane_Collosion_Case2, FR_Top_To_Bott_RLane_Collosion_Master_Cases;
	logic FR_Top_To_Bott_LLane_Collosion_Case1, FR_Top_To_Bott_LLane_Collosion_Case2, FR_Top_To_Bott_LLane_Collosion_Master_Cases;
	logic FR_Bott_To_Top_RLane_Collosion_Case1, FR_Bott_To_Top_RLane_Collosion_Case2, FR_Bott_To_Top_RLane_Collosion_Master_Cases;
	logic FR_Bott_To_Top_LLane_Collosion_Case1, FR_Bott_To_Top_LLane_Collosion_Case2, FR_Bott_To_Top_LLane_Collosion_Master_Cases;

	
	// COLLISION CASE LOGIC
	assign FR_Top_To_Bott_RLane_Collosion_Case1 = car_move_array_FR_TRoad_LLane_V[04][0] || car_move_array_FR_TRoad_LLane_V[03][0];
	assign FR_Top_To_Bott_RLane_Collosion_Case2 = car_move_array_FR_BRoad_RLane[0][10]   || car_move_array_FR_BRoad_RLane[0][9];
	
	assign FR_Top_To_Bott_LLane_Collosion_Case1 = car_move_array_FR_TRoad_LLane_V[01][0] || car_move_array_FR_TRoad_LLane_V[00][0];
	assign FR_Top_To_Bott_LLane_Collosion_Case2 = car_move_array_FR_BRoad_LLane_H[0][07] || car_move_array_FR_BRoad_LLane_H[0][06];
	
	assign FR_Bott_To_Top_RLane_Collosion_Case1 = car_move_array_FR_TRoad_RLane[0][4]   || car_move_array_FR_TRoad_RLane[0][3];
	assign FR_Bott_To_Top_RLane_Collosion_Case2 = car_move_array_FR_BRoad_LLane_V[3][0]   || car_move_array_FR_BRoad_LLane_V[2][0];
	
	assign FR_Bott_To_Top_LLane_Collosion_Case1 = car_move_array_FR_TRoad_LLane_H[0][4] || car_move_array_FR_TRoad_LLane_H[0][3];
	assign FR_Bott_To_Top_LLane_Collosion_Case2 = car_move_array_FR_BRoad_LLane_V[6][0] || car_move_array_FR_BRoad_LLane_V[5][0];
	
	
	// MASTER COLLISION CASE LOGIC 
	assign FR_Top_To_Bott_RLane_Collosion_Master_Cases = FR_Top_To_Bott_RLane_Collosion_Case1 && FR_Top_To_Bott_RLane_Collosion_Case2;
	
	assign FR_Top_To_Bott_LLane_Collosion_Master_Cases = FR_Top_To_Bott_LLane_Collosion_Case1 && FR_Top_To_Bott_LLane_Collosion_Case2;
	
	assign FR_Bott_To_Top_RLane_Collosion_Master_Cases = FR_Bott_To_Top_RLane_Collosion_Case1 && FR_Bott_To_Top_RLane_Collosion_Case2;
	
	assign FR_Bott_To_Top_LLane_Collosion_Master_Cases = FR_Bott_To_Top_LLane_Collosion_Case1 && FR_Bott_To_Top_LLane_Collosion_Case2;
	
	
	// MASTER COLLISION COUNTER LOGIC
	assign master_Collision_Counter = collision_Counter_Top_Turn_Car_LLane_Crash + collision_Counter_Top_Turn_Car_RLane_Crash +
	                                  collision_Counter_Bot_Turn_Car_LLane_Crash + collision_Counter_Bot_Turn_Car_RLane_Crash;
	
	
	// DISCRIPTION: MANAGES THE COLLISIONS FOR THE BOTTOM FARM ROAD RIGHT LANE 
   collision_Intersect FR_TOP_TO_BOTT_RLANE_COLLISION (.traffic_clk(clk_traffic), .reset(reset), .collision_Cases(FR_Top_To_Bott_RLane_Collosion_Master_Cases),
																	    .turning_Car_Incoming(car_move_array_FR_TRoad_LLane_V[02][0]), .show_Pass(show_Pass_Top_Turn_Car_RLane_Crash), 
																		 .collision_Counter(collision_Counter_Top_Turn_Car_RLane_Crash), 
																		 .show_Crash(show_Crash_Top_Turn_Car_RLane_Crash));	
	
   // DISCRIPTION: MANAGES THE COLLISIONS FOR THE BOTTOM FARM ROAD LEFT LANE 	
   collision_Intersect FR_TOP_TO_BOTT_LLANE_COLLISION (.traffic_clk(clk_traffic), .reset(reset), .collision_Cases(FR_Top_To_Bott_LLane_Collosion_Master_Cases),
																	    .turning_Car_Incoming(car_move_array_FR_TRoad_LLane_H[1][10]), .show_Pass(show_Pass_Top_Turn_Car_LLane_Crash), 
																		 .collision_Counter(collision_Counter_Top_Turn_Car_LLane_Crash), 
																		 .show_Crash(show_Crash_Top_Turn_Car_LLane_Crash)); 
	
   // DISCRIPTION: MANAGES THE COLLISIONS FOR THE TOP FARM ROAD RIGHT LANE 	
   collision_Intersect FR_BOTT_TO_TOP_RLANE_COLLISION (.traffic_clk(clk_traffic), .reset(reset), .collision_Cases(FR_Bott_To_Top_RLane_Collosion_Master_Cases),
																	    .turning_Car_Incoming(car_move_array_FR_BRoad_LLane_V[04][0]), .show_Pass(show_Pass_Bott_Turn_Car_RLane_Crash), 
																		 .collision_Counter(collision_Counter_Bot_Turn_Car_RLane_Crash), 
																		 .show_Crash(show_Crash_Bott_Turn_Car_RLane_Crash));	
	
   // DISCRIPTION: MANAGES THE COLLISIONS FOR THE TOP FARM ROAD LEFT LANE 	
   collision_Intersect FR_BOTT_TO_TOP_LLANE_COLLISION (.traffic_clk(clk_traffic), .reset(reset), .collision_Cases(FR_Bott_To_Top_LLane_Collosion_Master_Cases),
																	    .turning_Car_Incoming(car_move_array_FR_BRoad_LLane_H[00][0]), .show_Pass(show_Pass_Bott_Turn_Car_LLane_Crash), 
																		 .collision_Counter(collision_Counter_Bot_Turn_Car_LLane_Crash), 
																		 .show_Crash(show_Crash_Bott_Turn_Car_LLane_Crash));
	
	
	/* ===================================================== HIGH WAY CARS ANIMATE ===================================================== */
	/* ================================================================================================================================= */
	
	// ===================================================== LEFT ROAD LEFT LANE ===================================================== //
	
	// DISCRIPTION: RANDOMLY ADDS THE CAR TO THE LED MATRIX
	add_Car_RandHW #(0) ADD_CAR_LEFT_ROAD_LLANE (.traffic_clk(clk_traffic), .reset(reset || highW_R_farm_G_i), .traffic_Level_SWs(traffic_Level_SWs_i), 
	                                             .highWay_Green(highW_G_farm_R_i), .add_Car(add_car_LRoad_LLane));
	
	// DISCRIPTION: CONTROLS THE ANIMATION FOR THE CAR
	carHW_Animate LROAD_LLANE (.traffic_clk(clk_traffic), .reset(reset || highW_R_farm_G_i), .add_car_rand(add_car_LRoad_LLane), .car_move_array(car_move_array_HW_LRoad_LLane));
	
	// ===================================================== LEFT ROAD RIGHT LANE ===================================================== //
	
	// DISCRIPTION: RANDOMLY ADDS THE CAR TO THE LED MATRIX
	add_Car_RandHW #(4) ADD_CAR_LEFT_ROAD_RLANE (.traffic_clk(clk_traffic), .reset(reset || highW_R_farm_G_i), .traffic_Level_SWs(traffic_Level_SWs_i), 
	                                             .highWay_Green(highW_G_farm_R_i), .add_Car(add_car_LRoad_RLane));
	
	// DISCRIPTION: CONTROLS THE ANIMATION FOR THE CAR 
	carHW_Animate LROAD_RLANE (.traffic_clk(clk_traffic), .reset(reset || highW_R_farm_G_i), .add_car_rand(add_car_LRoad_RLane), .car_move_array(car_move_array_HW_LRoad_RLane));
	
	
	// ===================================================== RIGHT ROAD LEFT LANE ===================================================== //
	
	// DISCRIPTION: RANDOMLY ADDS THE CAR TO THE LED MATRIX
	add_Car_RandHW #(8) ADD_CAR_RIGHT_ROAD_LLANE (.traffic_clk(clk_traffic), .reset(reset || highW_R_farm_G_i), .traffic_Level_SWs(traffic_Level_SWs_i), 
	                                             .highWay_Green(highW_G_farm_R_i), .add_Car(add_car_RRoad_LLane));
	 
	// DISCRIPTION: CONTROLS THE ANIMATION FOR THE CAR
	carHW_Animate RROAD_LLANE (.traffic_clk(clk_traffic), .reset(reset || highW_R_farm_G_i), .add_car_rand(add_car_RRoad_LLane), .car_move_array(car_move_array_HW_RRoad_LLane));
	
	// ===================================================== RIGHT ROAD RIGHT LANE ===================================================== //
	
	// DISCRIPTION: RANDOMLY ADDS THE CAR TO THE LED MATRIX
	add_Car_RandHW #(12) ADD_CAR_RIGHT_ROAD_RLANE (.traffic_clk(clk_traffic), .reset(reset || highW_R_farm_G_i), .traffic_Level_SWs(traffic_Level_SWs_i), 
	                                             .highWay_Green(highW_G_farm_R_i), .add_Car(add_car_RRoad_RLane));
	 
	// DISCRIPTION: CONTROLS THE ANIMATION FOR THE CAR 
	carHW_Animate RROAD_RLANE (.traffic_clk(clk_traffic), .reset(reset || highW_R_farm_G_i), .add_car_rand(add_car_RRoad_RLane), .car_move_array(car_move_array_HW_RRoad_RLane));
   /* ================================================================================================================================= */
	
	
	
	/* ===================================================== FARM ROAD CARS ANIMATE ===================================================== */
	/* ================================================================================================================================== */
	
	// ===================================================== TOP ROAD RIGHT LANE STRAIGHT ===================================================== //
	
	// DISCRIPTION: MANAGES THE CAR QUEUE COUNTER AND RANDOMLY ADDS THOSE CARS TO THE LED MATRIX
	add_Car_FR_Wrapper #(0) ADD_CAR_TOP_ROAD_RLANE (.traffic_clk(clk_traffic), .reset(reset), .FarmRoad_Green(highW_R_farm_G_i), 
	                                                .add_car_to_queue(add_car_to_FR_TRoad_RLane_i), .dec_car_in_queue(dec_car_in_FR_TRoad_RLane), 
																	.traffic_Level_SWs(traffic_Level_SWs_i), .add_Car(add_car_animate_FR_TRoad_RLane), 
																	.car_queue_counter(car_queue_counter_FR_TRoad_RLane));
	
	// DISCRPTION: CONTROLS THE ANIMATION FOR THE CAR 
	carFR_Straight_Animate TOP_RLANE(.traffic_clk(clk_traffic), .reset(reset || highW_G_farm_R_i), .add_car(add_car_animate_FR_TRoad_RLane), 
	                                 .car_move_array(car_move_array_FR_TRoad_RLane), .decrement_car(dec_car_in_FR_TRoad_RLane));
												
		
	// ===================================================== BOTTOM ROAD RIGHT LANE STRAIGHT ===================================================== //
	
	// DISCRIPTION: MANAGES TEH CAR QUEUE COUNTER AND RANDOMLY ADDS THOSE CARS TO TEH LED MATRIX
	add_Car_FR_Wrapper #(4) ADD_CAR_BOTTOM_ROAD_RLANE (.traffic_clk(clk_traffic), .reset(reset), .FarmRoad_Green(highW_R_farm_G_i), 
	                                                .add_car_to_queue(add_car_to_FR_BRoad_RLane_i), .dec_car_in_queue(dec_car_in_FR_BRoad_RLane), 
																	.traffic_Level_SWs(traffic_Level_SWs_i), .add_Car(add_car_animate_FR_BRoad_RLane), 
																	.car_queue_counter(car_queue_counter_FR_BRoad_RLane));
	
	// DISCRIPTION: CONTROLS THE ANIMATION FOR THE CAR 
	carFR_Straight_Left_To_Right_Animate BOTTOM_RLANE (.traffic_clk(clk_traffic), .reset(reset || highW_G_farm_R_i), .add_car(add_car_animate_FR_BRoad_RLane), 
	                                 .car_move_array(car_move_array_FR_BRoad_RLane), .decrement_car(dec_car_in_FR_BRoad_RLane));
												
	
	// ===================================================== TOP ROAD LEFT LANE TURN ===================================================== //
	
	// DISCRIPTION: MANAGES TEH CAR QUEUE COUNTER AND RANDOMLY ADDS THOSE CARS TO TEH LED MATRIX
	add_Car_FR_Wrapper #(8) ADD_CAR_TOP_ROAD_LLANE (.traffic_clk(clk_traffic), .reset(reset), .FarmRoad_Green(highW_R_farm_G_i), 
	                                                .add_car_to_queue(add_car_to_FR_TRoad_LLane_Turn_i), .dec_car_in_queue(dec_car_in_FR_TRoad_LLane), 
																	.traffic_Level_SWs(traffic_Level_SWs_i), .add_Car(add_car_animate_FR_TRoad_LLane_From_Add_Module), 
																	.car_queue_counter(car_queue_counter_FR_TRoad_LLane));
	
	// DISCRIPTION: CONTROLS THE ANIMATION FOR THE CAR 
	carFR_Turn_Animate_Top_To_Bottom TOP_LLANE(.traffic_clk(clk_traffic), .reset(reset || highW_G_farm_R_i), .add_car(add_car_animate_FR_TRoad_LLane), 
	                                 .car_move_array_h(car_move_array_FR_TRoad_LLane_H), .car_move_array_v(car_move_array_FR_TRoad_LLane_V), 
												.decrement_car(dec_car_in_FR_TRoad_LLane));
												
		
	// ===================================================== BOTTOM ROAD LEFT LANE TURN ===================================================== //
	
	// DISCRIPTION: MANAGES TEH CAR QUEUE COUNTER AND RANDOMLY ADDS THOSE CARS TO TEH LED MATRIX
	add_Car_FR_Wrapper #(12) ADD_CAR_BOTTOM_ROAD_LLANE (.traffic_clk(clk_traffic), .reset(reset), .FarmRoad_Green(highW_R_farm_G_i), 
	                                                .add_car_to_queue(add_car_to_FR_BRoad_LLane_Turn_i), .dec_car_in_queue(dec_car_in_FR_BRoad_LLane), 
																	.traffic_Level_SWs(traffic_Level_SWs_i), .add_Car(add_car_animate_FR_BRoad_LLane_From_Add_Module), 
																	.car_queue_counter(car_queue_counter_FR_BRoad_LLane));
	
	// DISCRIPTION: CONTROLS THE ANIMATION FOR THE CAR 
	carFR_Turn_Animate_Bottom_To_Top BOTTOM_LLANE (.traffic_clk(clk_traffic), .reset(reset || highW_G_farm_R_i), .add_car(add_car_animate_FR_BRoad_LLane), 
	                                 .car_move_array_h(car_move_array_FR_BRoad_LLane_H), .car_move_array_v(car_move_array_FR_BRoad_LLane_V), 
												.decrement_car(dec_car_in_FR_BRoad_LLane));
	
	
	always_comb begin
	   // ENTER IF HIGH WAY LIGHT = GREEN, FARM LIGHT = RED
		if (highW_G_farm_R_i) begin
		
			GrnPixels[00] = {2'b00, car_move_array_HW_LRoad_LLane[00], 1'b0, car_move_array_HW_LRoad_RLane[00],                                                                             9'b011111100};
		   GrnPixels[01] = {2'b00, car_move_array_HW_LRoad_LLane[01], 1'b0, car_move_array_HW_LRoad_RLane[01],                                                                             9'b011111100};
			GrnPixels[02] = {2'b00, car_move_array_HW_LRoad_LLane[02], 1'b0, car_move_array_HW_LRoad_RLane[02], 2'b00, car_move_array_HW_RRoad_LLane[13], 1'b0, car_move_array_HW_RRoad_RLane[13], 2'b00};
			GrnPixels[03] = {2'b00, car_move_array_HW_LRoad_LLane[03], 1'b0, car_move_array_HW_LRoad_RLane[03], 2'b00, car_move_array_HW_RRoad_LLane[12], 1'b0, car_move_array_HW_RRoad_RLane[12], 2'b00};
			GrnPixels[04] = {2'b00, car_move_array_HW_LRoad_LLane[04], 1'b0, car_move_array_HW_LRoad_RLane[04], 2'b00, car_move_array_HW_RRoad_LLane[11], 1'b0, car_move_array_HW_RRoad_RLane[11], 2'b00};
			GrnPixels[05] = {2'b00, car_move_array_HW_LRoad_LLane[05], 1'b0, car_move_array_HW_LRoad_RLane[05], 2'b00, car_move_array_HW_RRoad_LLane[10], 1'b0, car_move_array_HW_RRoad_RLane[10], 2'b00};
			GrnPixels[06] = {2'b00, car_move_array_HW_LRoad_LLane[06], 1'b0, car_move_array_HW_LRoad_RLane[06], 2'b00, car_move_array_HW_RRoad_LLane[09], 1'b0, car_move_array_HW_RRoad_RLane[09], 2'b00};
			GrnPixels[07] = {2'b00, car_move_array_HW_LRoad_LLane[07], 1'b0, car_move_array_HW_LRoad_RLane[07], 2'b00, car_move_array_HW_RRoad_LLane[08], 1'b0, car_move_array_HW_RRoad_RLane[08], 2'b00};
		
			GrnPixels[08] = {2'b00, car_move_array_HW_LRoad_LLane[08], 1'b0, car_move_array_HW_LRoad_RLane[08], 2'b00, car_move_array_HW_RRoad_LLane[07], 1'b0, car_move_array_HW_RRoad_RLane[07], 2'b00};
			GrnPixels[09] = {2'b00, car_move_array_HW_LRoad_LLane[09], 1'b0, car_move_array_HW_LRoad_RLane[09], 2'b00, car_move_array_HW_RRoad_LLane[06], 1'b0, car_move_array_HW_RRoad_RLane[06], 2'b00};
			GrnPixels[10] = {2'b00, car_move_array_HW_LRoad_LLane[10], 1'b0, car_move_array_HW_LRoad_RLane[10], 2'b00, car_move_array_HW_RRoad_LLane[05], 1'b0, car_move_array_HW_RRoad_RLane[05], 2'b00};
			GrnPixels[11] = {2'b00, car_move_array_HW_LRoad_LLane[11], 1'b0, car_move_array_HW_LRoad_RLane[11], 2'b00, car_move_array_HW_RRoad_LLane[04], 1'b0, car_move_array_HW_RRoad_RLane[04], 2'b00};
			GrnPixels[12] = {2'b00, car_move_array_HW_LRoad_LLane[12], 1'b0, car_move_array_HW_LRoad_RLane[12], 2'b00, car_move_array_HW_RRoad_LLane[03], 1'b0, car_move_array_HW_RRoad_RLane[03], 2'b00};
			GrnPixels[13] = {2'b00, car_move_array_HW_LRoad_LLane[13], 1'b0, car_move_array_HW_LRoad_RLane[13], 2'b00, car_move_array_HW_RRoad_LLane[02], 1'b0, car_move_array_HW_RRoad_RLane[02], 2'b00};
			GrnPixels[14] = {9'b001111110,                                                                             car_move_array_HW_RRoad_LLane[01], 1'b0, car_move_array_HW_RRoad_RLane[01], 2'b00};
		   GrnPixels[15] = {9'b001111110,                                                                             car_move_array_HW_RRoad_LLane[00], 1'b0, car_move_array_HW_RRoad_RLane[00], 2'b00};
			
			
			
			
			RedPixels[00] = {2'b00, car_move_array_HW_LRoad_LLane[00], 1'b0, car_move_array_HW_LRoad_RLane[00],                                                                             9'b000000000};
		   RedPixels[01] = {2'b00, car_move_array_HW_LRoad_LLane[01], 1'b0, car_move_array_HW_LRoad_RLane[01],                                                                             9'b000000000};
			RedPixels[02] = {2'b11, car_move_array_HW_LRoad_LLane[02], 1'b0, car_move_array_HW_LRoad_RLane[02], 2'b00, car_move_array_HW_RRoad_LLane[13], 1'b0, car_move_array_HW_RRoad_RLane[13], 2'b00};
			RedPixels[03] = {2'b11, car_move_array_HW_LRoad_LLane[03], 1'b0, car_move_array_HW_LRoad_RLane[03], 2'b00, car_move_array_HW_RRoad_LLane[12], 1'b0, car_move_array_HW_RRoad_RLane[12], 2'b00};
			RedPixels[04] = {2'b11, car_move_array_HW_LRoad_LLane[04], 1'b0, car_move_array_HW_LRoad_RLane[04], 2'b00, car_move_array_HW_RRoad_LLane[11], 1'b0, car_move_array_HW_RRoad_RLane[11], 2'b00};
			RedPixels[05] = {2'b11, car_move_array_HW_LRoad_LLane[05], 1'b0, car_move_array_HW_LRoad_RLane[05], 2'b00, car_move_array_HW_RRoad_LLane[10], 1'b0, car_move_array_HW_RRoad_RLane[10], 2'b00};
			RedPixels[06] = {2'b11, car_move_array_HW_LRoad_LLane[06], 1'b0, car_move_array_HW_LRoad_RLane[06], 2'b00, car_move_array_HW_RRoad_LLane[09], 1'b0, car_move_array_HW_RRoad_RLane[09], 2'b00};
			RedPixels[07] = {2'b11, car_move_array_HW_LRoad_LLane[07], 1'b0, car_move_array_HW_LRoad_RLane[07], 2'b00, car_move_array_HW_RRoad_LLane[08], 1'b0, car_move_array_HW_RRoad_RLane[08], 2'b00};
		
			RedPixels[08] = {2'b00, car_move_array_HW_LRoad_LLane[08], 1'b0, car_move_array_HW_LRoad_RLane[08], 2'b00, car_move_array_HW_RRoad_LLane[07], 1'b0, car_move_array_HW_RRoad_RLane[07], 2'b11};
			RedPixels[09] = {2'b00, car_move_array_HW_LRoad_LLane[09], 1'b0, car_move_array_HW_LRoad_RLane[09], 2'b00, car_move_array_HW_RRoad_LLane[06], 1'b0, car_move_array_HW_RRoad_RLane[06], 2'b11};
			RedPixels[10] = {2'b00, car_move_array_HW_LRoad_LLane[10], 1'b0, car_move_array_HW_LRoad_RLane[10], 2'b00, car_move_array_HW_RRoad_LLane[05], 1'b0, car_move_array_HW_RRoad_RLane[05], 2'b11};
			RedPixels[11] = {2'b00, car_move_array_HW_LRoad_LLane[11], 1'b0, car_move_array_HW_LRoad_RLane[11], 2'b00, car_move_array_HW_RRoad_LLane[04], 1'b0, car_move_array_HW_RRoad_RLane[04], 2'b11};
			RedPixels[12] = {2'b00, car_move_array_HW_LRoad_LLane[12], 1'b0, car_move_array_HW_LRoad_RLane[12], 2'b00, car_move_array_HW_RRoad_LLane[03], 1'b0, car_move_array_HW_RRoad_RLane[03], 2'b11};
			RedPixels[13] = {2'b00, car_move_array_HW_LRoad_LLane[13], 1'b0, car_move_array_HW_LRoad_RLane[13], 2'b00, car_move_array_HW_RRoad_LLane[02], 1'b0, car_move_array_HW_RRoad_RLane[02], 2'b11};
			RedPixels[14] = {9'b000000000,                                                                             car_move_array_HW_RRoad_LLane[01], 1'b0, car_move_array_HW_RRoad_RLane[01], 2'b00};
		   RedPixels[15] = {9'b000000000,                                                                             car_move_array_HW_RRoad_LLane[00], 1'b0, car_move_array_HW_RRoad_RLane[00], 2'b00};                                                                            
			
		end
		
		/* =================================================================================================================================================== */
		/* =================================================================================================================================================== */
		
		// ENTER IF HIGH WAY LIGHT = YELLOW, FARM LIGHT = RED
		else if (highW_Y_farm_R_i) begin
		
			GrnPixels[00] = {2'b00, car_move_array_HW_LRoad_LLane[00], 1'b0, car_move_array_HW_LRoad_RLane[00],                                                                             9'b011111100};
		   GrnPixels[01] = {2'b00, car_move_array_HW_LRoad_LLane[01], 1'b0, car_move_array_HW_LRoad_RLane[01],                                                                             9'b011111100};
			GrnPixels[02] = {2'b00, car_move_array_HW_LRoad_LLane[02], 1'b0, car_move_array_HW_LRoad_RLane[02], 2'b00, car_move_array_HW_RRoad_LLane[13], 1'b0, car_move_array_HW_RRoad_RLane[13], 2'b00};
			GrnPixels[03] = {2'b00, car_move_array_HW_LRoad_LLane[03], 1'b0, car_move_array_HW_LRoad_RLane[03], 2'b00, car_move_array_HW_RRoad_LLane[12], 1'b0, car_move_array_HW_RRoad_RLane[12], 2'b00};
			GrnPixels[04] = {2'b00, car_move_array_HW_LRoad_LLane[04], 1'b0, car_move_array_HW_LRoad_RLane[04], 2'b00, car_move_array_HW_RRoad_LLane[11], 1'b0, car_move_array_HW_RRoad_RLane[11], 2'b00};
			GrnPixels[05] = {2'b00, car_move_array_HW_LRoad_LLane[05], 1'b0, car_move_array_HW_LRoad_RLane[05], 2'b00, car_move_array_HW_RRoad_LLane[10], 1'b0, car_move_array_HW_RRoad_RLane[10], 2'b00};
			GrnPixels[06] = {2'b00, car_move_array_HW_LRoad_LLane[06], 1'b0, car_move_array_HW_LRoad_RLane[06], 2'b00, car_move_array_HW_RRoad_LLane[09], 1'b0, car_move_array_HW_RRoad_RLane[09], 2'b00};
			GrnPixels[07] = {2'b00, car_move_array_HW_LRoad_LLane[07], 1'b0, car_move_array_HW_LRoad_RLane[07], 2'b00, car_move_array_HW_RRoad_LLane[08], 1'b0, car_move_array_HW_RRoad_RLane[08], 2'b00};
		
			GrnPixels[08] = {2'b00, car_move_array_HW_LRoad_LLane[08], 1'b0, car_move_array_HW_LRoad_RLane[08], 2'b00, car_move_array_HW_RRoad_LLane[07], 1'b0, car_move_array_HW_RRoad_RLane[07], 2'b00};
			GrnPixels[09] = {2'b00, car_move_array_HW_LRoad_LLane[09], 1'b0, car_move_array_HW_LRoad_RLane[09], 2'b00, car_move_array_HW_RRoad_LLane[06], 1'b0, car_move_array_HW_RRoad_RLane[06], 2'b00};
			GrnPixels[10] = {2'b00, car_move_array_HW_LRoad_LLane[10], 1'b0, car_move_array_HW_LRoad_RLane[10], 2'b00, car_move_array_HW_RRoad_LLane[05], 1'b0, car_move_array_HW_RRoad_RLane[05], 2'b00};
			GrnPixels[11] = {2'b00, car_move_array_HW_LRoad_LLane[11], 1'b0, car_move_array_HW_LRoad_RLane[11], 2'b00, car_move_array_HW_RRoad_LLane[04], 1'b0, car_move_array_HW_RRoad_RLane[04], 2'b00};
			GrnPixels[12] = {2'b00, car_move_array_HW_LRoad_LLane[12], 1'b0, car_move_array_HW_LRoad_RLane[12], 2'b00, car_move_array_HW_RRoad_LLane[03], 1'b0, car_move_array_HW_RRoad_RLane[03], 2'b00};
			GrnPixels[13] = {2'b00, car_move_array_HW_LRoad_LLane[13], 1'b0, car_move_array_HW_LRoad_RLane[13], 2'b00, car_move_array_HW_RRoad_LLane[02], 1'b0, car_move_array_HW_RRoad_RLane[02], 2'b00};
			GrnPixels[14] = {9'b001111110,                                                                             car_move_array_HW_RRoad_LLane[01], 1'b0, car_move_array_HW_RRoad_RLane[01], 2'b00};
		   GrnPixels[15] = {9'b001111110,                                                                             car_move_array_HW_RRoad_LLane[00], 1'b0, car_move_array_HW_RRoad_RLane[00], 2'b00};
			
			
			
			
			RedPixels[00] = {2'b00, car_move_array_HW_LRoad_LLane[00], 1'b0, car_move_array_HW_LRoad_RLane[00],                                                                             9'b011111100};
		   RedPixels[01] = {2'b00, car_move_array_HW_LRoad_LLane[01], 1'b0, car_move_array_HW_LRoad_RLane[01],                                                                             9'b011111100};
			RedPixels[02] = {2'b11, car_move_array_HW_LRoad_LLane[02], 1'b0, car_move_array_HW_LRoad_RLane[02], 2'b00, car_move_array_HW_RRoad_LLane[13], 1'b0, car_move_array_HW_RRoad_RLane[13], 2'b00};
			RedPixels[03] = {2'b11, car_move_array_HW_LRoad_LLane[03], 1'b0, car_move_array_HW_LRoad_RLane[03], 2'b00, car_move_array_HW_RRoad_LLane[12], 1'b0, car_move_array_HW_RRoad_RLane[12], 2'b00};
			RedPixels[04] = {2'b11, car_move_array_HW_LRoad_LLane[04], 1'b0, car_move_array_HW_LRoad_RLane[04], 2'b00, car_move_array_HW_RRoad_LLane[11], 1'b0, car_move_array_HW_RRoad_RLane[11], 2'b00};
			RedPixels[05] = {2'b11, car_move_array_HW_LRoad_LLane[05], 1'b0, car_move_array_HW_LRoad_RLane[05], 2'b00, car_move_array_HW_RRoad_LLane[10], 1'b0, car_move_array_HW_RRoad_RLane[10], 2'b00};
			RedPixels[06] = {2'b11, car_move_array_HW_LRoad_LLane[06], 1'b0, car_move_array_HW_LRoad_RLane[06], 2'b00, car_move_array_HW_RRoad_LLane[09], 1'b0, car_move_array_HW_RRoad_RLane[09], 2'b00};
			RedPixels[07] = {2'b11, car_move_array_HW_LRoad_LLane[07], 1'b0, car_move_array_HW_LRoad_RLane[07], 2'b00, car_move_array_HW_RRoad_LLane[08], 1'b0, car_move_array_HW_RRoad_RLane[08], 2'b00};
		
			RedPixels[08] = {2'b00, car_move_array_HW_LRoad_LLane[08], 1'b0, car_move_array_HW_LRoad_RLane[08], 2'b00, car_move_array_HW_RRoad_LLane[07], 1'b0, car_move_array_HW_RRoad_RLane[07], 2'b11};
			RedPixels[09] = {2'b00, car_move_array_HW_LRoad_LLane[09], 1'b0, car_move_array_HW_LRoad_RLane[09], 2'b00, car_move_array_HW_RRoad_LLane[06], 1'b0, car_move_array_HW_RRoad_RLane[06], 2'b11};
			RedPixels[10] = {2'b00, car_move_array_HW_LRoad_LLane[10], 1'b0, car_move_array_HW_LRoad_RLane[10], 2'b00, car_move_array_HW_RRoad_LLane[05], 1'b0, car_move_array_HW_RRoad_RLane[05], 2'b11};
			RedPixels[11] = {2'b00, car_move_array_HW_LRoad_LLane[11], 1'b0, car_move_array_HW_LRoad_RLane[11], 2'b00, car_move_array_HW_RRoad_LLane[04], 1'b0, car_move_array_HW_RRoad_RLane[04], 2'b11};
			RedPixels[12] = {2'b00, car_move_array_HW_LRoad_LLane[12], 1'b0, car_move_array_HW_LRoad_RLane[12], 2'b00, car_move_array_HW_RRoad_LLane[03], 1'b0, car_move_array_HW_RRoad_RLane[03], 2'b11};
			RedPixels[13] = {2'b00, car_move_array_HW_LRoad_LLane[13], 1'b0, car_move_array_HW_LRoad_RLane[13], 2'b00, car_move_array_HW_RRoad_LLane[02], 1'b0, car_move_array_HW_RRoad_RLane[02], 2'b11};
			RedPixels[14] = {9'b001111110,                                                                             car_move_array_HW_RRoad_LLane[01], 1'b0, car_move_array_HW_RRoad_RLane[01], 2'b00};
		   RedPixels[15] = {9'b001111110,                                                                             car_move_array_HW_RRoad_LLane[00], 1'b0, car_move_array_HW_RRoad_RLane[00], 2'b00};                                                                            
			

		end
		
		/* =================================================================================================================================================== */
		/* =================================================================================================================================================== */
		
		// ENTER IF HIGH WAY LIGHT = RED, FARM LIGHT = GREEN
		else if (highW_R_farm_G_i) begin
			

			RedPixels[00] = 16'b0000000011111100;
		   RedPixels[01] = 16'b0000000011111100;
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			RedPixels[02][15:7] = {2'b00, car_move_array_FR_TRoad_RLane[0][13:7]};       
			RedPixels[02][4:0]   = {car_move_array_FR_TRoad_RLane[0][4:0]}; 
			
			RedPixels[03][15:7] = {2'b00, car_move_array_FR_TRoad_RLane[1][13:7]}; 
			RedPixels[03][4:0]   = {car_move_array_FR_TRoad_RLane[1][4:0]};

			if (show_Pass_Bott_Turn_Car_RLane_Crash) begin
				RedPixels[02][6:5] = car_move_array_FR_BRoad_LLane_V[00];  
		      RedPixels[03][6:5] = car_move_array_FR_BRoad_LLane_V[01];  
			end
			else if (show_Crash_Bott_Turn_Car_RLane_Crash) begin
				RedPixels[02][6:5] = 2'b11;
				RedPixels[03][6:5] = 2'b11;
			end
			else begin
				RedPixels[02][6:5] = car_move_array_FR_TRoad_RLane[0][6:5];
				RedPixels[03][6:5] = car_move_array_FR_TRoad_RLane[1][6:5];
			end	
			/* ================================================================================ */

		   RedPixels[04] = {9'b000000000, car_move_array_FR_BRoad_LLane_V[02],5'b00000};
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
         /* ================================================================================ */
			RedPixels[05][15:7] = {5'b00000, car_move_array_FR_TRoad_LLane_H[0][10:7]};        
			RedPixels[05][4:0]   = {car_move_array_FR_TRoad_LLane_H[0][4:0]}; 

			RedPixels[06][15:7] = {5'b00000, car_move_array_FR_TRoad_LLane_H[1][10:7]};
			RedPixels[06][4:0]   = {car_move_array_FR_TRoad_LLane_H[1][4:0]};

			if (show_Pass_Bott_Turn_Car_LLane_Crash) begin
				RedPixels[05][6:5] = car_move_array_FR_BRoad_LLane_V[03];  
		      RedPixels[06][6:5] = car_move_array_FR_BRoad_LLane_V[04];  
			end
			else if (show_Crash_Bott_Turn_Car_LLane_Crash) begin
				RedPixels[05][6:5] = 2'b11;
				RedPixels[06][6:5] = 2'b11;
			end
			else begin
				RedPixels[05][6:5] = car_move_array_FR_TRoad_LLane_H[0][5:4];
				RedPixels[06][6:5] = car_move_array_FR_TRoad_LLane_H[1][5:4];
			end				
			/* ================================================================================ */
			

		   RedPixels[07] = {5'b00000, car_move_array_FR_TRoad_LLane_V[00],2'b00, car_move_array_FR_BRoad_LLane_V[05], 5'b00000};
			
			RedPixels[08] = {5'b00000, car_move_array_FR_TRoad_LLane_V[01], 2'b00, car_move_array_FR_BRoad_LLane_V[06], 5'b00000};
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			RedPixels[09][15:11] = car_move_array_FR_BRoad_LLane_H[1][10:6];        
			RedPixels[09][8:0]   = {car_move_array_FR_BRoad_LLane_H[1][3:0], 5'b00000};
			
			RedPixels[10][15:11] = car_move_array_FR_BRoad_LLane_H[0][10:6];
			RedPixels[10][8:0]   = {car_move_array_FR_BRoad_LLane_H[0][3:0], 5'b00000};
			
			if (show_Pass_Top_Turn_Car_LLane_Crash) begin
				RedPixels[09][10:9] = car_move_array_FR_TRoad_LLane_V[02];  
		      RedPixels[10][10:9] = car_move_array_FR_TRoad_LLane_V[03];  
			end
			else if (show_Crash_Top_Turn_Car_LLane_Crash) begin
				RedPixels[09][10:9] = 2'b11;
				RedPixels[10][10:9] = 2'b11;
			end
			else begin
				RedPixels[09][10:9] = car_move_array_FR_BRoad_LLane_H[1][5:4];
				RedPixels[10][10:9] = car_move_array_FR_BRoad_LLane_H[0][5:4];
			end	
			/* ================================================================================ */
			
		   RedPixels[11] = {5'b00000, car_move_array_FR_TRoad_LLane_V[04], 9'b000000000};
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			RedPixels[12][15:11] = car_move_array_FR_BRoad_RLane[0][13:9];        
			RedPixels[12][8:0]   = {car_move_array_FR_BRoad_RLane[0][6:0], 2'b00};
			
			RedPixels[13][15:11] = car_move_array_FR_BRoad_RLane[1][13:9];
			RedPixels[13][8:0]   = {car_move_array_FR_BRoad_RLane[1][6:0], 2'b00};
			
			if (show_Pass_Top_Turn_Car_RLane_Crash) begin
				RedPixels[12][10:9] = car_move_array_FR_TRoad_LLane_V[05];  
		      RedPixels[13][10:9] = car_move_array_FR_TRoad_LLane_V[06];  
			end
			else if (show_Crash_Top_Turn_Car_RLane_Crash) begin
				RedPixels[12][10:9] = 2'b11;
				RedPixels[13][10:9] = 2'b11;
			end
			else begin
				RedPixels[12][10:9] = car_move_array_FR_BRoad_RLane[0][8:7];
				RedPixels[13][10:9] = car_move_array_FR_BRoad_RLane[1][8:7];
			end
			/* ================================================================================ */
			
		   RedPixels[14] = 16'b0011111100000000;
		   RedPixels[15] = 16'b0011111100000000;			
			
			
			
			GrnPixels[00] = 16'b0000000000000000;
		   GrnPixels[01] = 16'b0000000000000000;
			
         // SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
        /* ================================================================================ */
			GrnPixels[02][15:7] = {2'b11, car_move_array_FR_TRoad_RLane[0][13:7]};       
			GrnPixels[02][4:0]   = {car_move_array_FR_TRoad_RLane[0][4:0]};
			
			GrnPixels[03][15:7] = {2'b11, car_move_array_FR_TRoad_RLane[1][13:7]}; 
			GrnPixels[03][4:0]   = {car_move_array_FR_TRoad_RLane[1][4:0]};
			
			if (show_Pass_Bott_Turn_Car_RLane_Crash) begin
				GrnPixels[02][6:5] = car_move_array_FR_BRoad_LLane_V[00];  
		      GrnPixels[03][6:5] = car_move_array_FR_BRoad_LLane_V[01];  
			end
			else if (show_Crash_Bott_Turn_Car_RLane_Crash) begin
				GrnPixels[02][6:5] = 2'b11;
				GrnPixels[03][6:5] = 2'b11;
			end
			else begin
				GrnPixels[02][6:5] = car_move_array_FR_TRoad_RLane[0][6:5];
				GrnPixels[03][6:5] = car_move_array_FR_TRoad_RLane[1][6:5];
			end				
			/* ================================================================================ */
			
			
		   GrnPixels[04] = {9'b110000000, car_move_array_FR_BRoad_LLane_V[02],5'b00000};
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			GrnPixels[05][15:7] = {5'b11000, car_move_array_FR_TRoad_LLane_H[0][10:7]};        
			GrnPixels[05][4:0]   = {car_move_array_FR_TRoad_LLane_H[0][4:0]}; 
			
			GrnPixels[06][15:7] = {5'b11000, car_move_array_FR_TRoad_LLane_H[1][10:7]};
			GrnPixels[06][4:0]   = {car_move_array_FR_TRoad_LLane_H[1][4:0]};
			
			if (show_Pass_Top_Turn_Car_LLane_Crash) begin
				GrnPixels[05][6:5] = car_move_array_FR_BRoad_LLane_V[03];  
		      GrnPixels[06][6:5] = car_move_array_FR_BRoad_LLane_V[04];  
			end
			else if (show_Crash_Top_Turn_Car_LLane_Crash) begin
				GrnPixels[05][6:5] = 2'b11;
				GrnPixels[06][6:5] = 2'b11;
			end
			else begin
				GrnPixels[05][6:5] = car_move_array_FR_TRoad_LLane_H[0][5:4];
				GrnPixels[06][6:5] = car_move_array_FR_TRoad_LLane_H[1][5:4];
			end				
			/* ================================================================================ */

			
		   GrnPixels[07] = {5'b11000, car_move_array_FR_TRoad_LLane_V[00],2'b00, car_move_array_FR_BRoad_LLane_V[05], 5'b00000};
			
			GrnPixels[08] = {5'b00000, car_move_array_FR_TRoad_LLane_V[01], 2'b00, car_move_array_FR_BRoad_LLane_V[06], 5'b00000};
			
         // SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			GrnPixels[09][15:11] = car_move_array_FR_BRoad_LLane_H[1][10:6];        
			GrnPixels[09][8:0]   = {car_move_array_FR_BRoad_LLane_H[1][3:0], 5'b00011}; 
			
			GrnPixels[10][15:11] = car_move_array_FR_BRoad_LLane_H[0][10:6];
			GrnPixels[10][8:0]   = {car_move_array_FR_BRoad_LLane_H[0][3:0], 5'b00011};
			
			if (show_Pass_Top_Turn_Car_LLane_Crash) begin
				GrnPixels[09][10:9] = car_move_array_FR_TRoad_LLane_V[02];  
		      GrnPixels[10][10:9] = car_move_array_FR_TRoad_LLane_V[03];  
			end
			else if (show_Crash_Top_Turn_Car_LLane_Crash) begin
				GrnPixels[09][10:9] = 2'b00;
				GrnPixels[10][10:9] = 2'b00;
			end
			else begin
				GrnPixels[09][10:9] = car_move_array_FR_BRoad_LLane_H[1][5:4];
				GrnPixels[10][10:9] = car_move_array_FR_BRoad_LLane_H[0][5:4];
			end			
			/* ================================================================================ */
			
			
		   GrnPixels[11] = {5'b00000, car_move_array_FR_TRoad_LLane_V[04], 9'b000000011};
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			GrnPixels[12][15:11] = car_move_array_FR_BRoad_RLane[0][13:9];        
			GrnPixels[12][8:0]   = {car_move_array_FR_BRoad_RLane[0][6:0], 2'b11};
			
			GrnPixels[13][15:11] = car_move_array_FR_BRoad_RLane[1][13:9];
			GrnPixels[13][8:0]   = {car_move_array_FR_BRoad_RLane[1][6:0], 2'b11};
			
			if (show_Pass_Top_Turn_Car_RLane_Crash) begin
				GrnPixels[12][10:9] = car_move_array_FR_TRoad_LLane_V[05];  
		      GrnPixels[13][10:9] = car_move_array_FR_TRoad_LLane_V[06];  
			end
			else if (show_Crash_Top_Turn_Car_RLane_Crash) begin
				GrnPixels[12][10:9] = 2'b00;
				GrnPixels[13][10:9] = 2'b00;
			end
			else begin
				GrnPixels[12][10:9] = car_move_array_FR_BRoad_RLane[0][8:7];
				GrnPixels[13][10:9] = car_move_array_FR_BRoad_RLane[1][8:7];
			end
			/* ================================================================================ */
			
		   GrnPixels[14] = 16'b0000000000000000;
		   GrnPixels[15] = 16'b0000000000000000;
		end
		
		/* =================================================================================================================================================== */
		/* =================================================================================================================================================== */
		
		// ENTER IF HIGH WAY LIGHT = RED, FARM LIGHT = YELLOW
		else if (highW_R_farm_Y_i) begin

			RedPixels[00] = 16'b0000000011111100;
		   RedPixels[01] = 16'b0000000011111100;
			
		  // SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
        /* ================================================================================ */
			RedPixels[02][15:7] = {2'b11, car_move_array_FR_TRoad_RLane[0][13:7]};       
			RedPixels[02][4:0]   = {car_move_array_FR_TRoad_RLane[0][4:0]};
			
			RedPixels[03][15:7] = {2'b11, car_move_array_FR_TRoad_RLane[1][13:7]}; 
			RedPixels[03][4:0]   = {car_move_array_FR_TRoad_RLane[1][4:0]};
			
			if (show_Pass_Bott_Turn_Car_RLane_Crash) begin
				RedPixels[02][6:5] = car_move_array_FR_BRoad_LLane_V[00];  
		      RedPixels[03][6:5] = car_move_array_FR_BRoad_LLane_V[01];  
			end
			else if (show_Crash_Bott_Turn_Car_RLane_Crash) begin
				RedPixels[02][6:5] = 2'b11;
				RedPixels[03][6:5] = 2'b11;
			end
			else begin
				RedPixels[02][6:5] = car_move_array_FR_TRoad_RLane[0][6:5];
				RedPixels[03][6:5] = car_move_array_FR_TRoad_RLane[1][6:5];
			end	
         /* ================================================================================ */
			
			
		   RedPixels[04] = {9'b110000000, car_move_array_FR_BRoad_LLane_V[02],5'b00000};
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			RedPixels[05][15:7] = {5'b11000, car_move_array_FR_TRoad_LLane_H[0][10:7]};        
			RedPixels[05][4:0]   = {car_move_array_FR_TRoad_LLane_H[0][4:0]}; 
		
			RedPixels[06][15:7] = {5'b11000, car_move_array_FR_TRoad_LLane_H[1][10:7]};
			RedPixels[06][4:0]   = {car_move_array_FR_TRoad_LLane_H[1][4:0]};

			if (show_Pass_Bott_Turn_Car_LLane_Crash) begin
				RedPixels[05][6:5] = car_move_array_FR_BRoad_LLane_V[03];  
		      RedPixels[06][6:5] = car_move_array_FR_BRoad_LLane_V[04];  
			end
			else if (show_Crash_Bott_Turn_Car_LLane_Crash) begin
				RedPixels[05][6:5] = 2'b11;
				RedPixels[06][6:5] = 2'b11;
			end
			else begin
				RedPixels[05][6:5] = car_move_array_FR_TRoad_LLane_H[0][5:4];
				RedPixels[06][6:5] = car_move_array_FR_TRoad_LLane_H[1][5:4];
			end				
			/* ================================================================================ */
			

		   RedPixels[07] = {5'b11000, car_move_array_FR_TRoad_LLane_V[00],2'b00, car_move_array_FR_BRoad_LLane_V[05], 5'b00000};
			
			RedPixels[08] = {5'b00000, car_move_array_FR_TRoad_LLane_V[01], 2'b00, car_move_array_FR_BRoad_LLane_V[06], 5'b00011};
			
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
         /* ================================================================================ */
			RedPixels[09][15:11] = car_move_array_FR_BRoad_LLane_H[1][10:6];        
			RedPixels[09][8:0]   = {car_move_array_FR_BRoad_LLane_H[1][3:0], 5'b00011}; 
			
			RedPixels[10][15:11] = car_move_array_FR_BRoad_LLane_H[0][10:6];
			RedPixels[10][8:0]   = {car_move_array_FR_BRoad_LLane_H[0][3:0], 5'b00011};
			
			if (show_Pass_Top_Turn_Car_LLane_Crash) begin
				RedPixels[09][10:9] = car_move_array_FR_TRoad_LLane_V[02];  
		      RedPixels[10][10:9] = car_move_array_FR_TRoad_LLane_V[03];  
			end
			else if (show_Crash_Top_Turn_Car_LLane_Crash) begin
				RedPixels[09][10:9] = 2'b11;
				RedPixels[10][10:9] = 2'b11;
			end
			else begin
				RedPixels[09][10:9] = car_move_array_FR_BRoad_LLane_H[1][5:4];
				RedPixels[10][10:9] = car_move_array_FR_BRoad_LLane_H[0][5:4];
			end	
			/* ================================================================================ */
			
			
		   RedPixels[11] = {5'b00000, car_move_array_FR_TRoad_LLane_V[04], 9'b000000011};
			
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			RedPixels[12][15:11] = car_move_array_FR_BRoad_RLane[0][13:9];        
			RedPixels[12][8:0]   = {car_move_array_FR_BRoad_RLane[0][6:0], 2'b11};
			
			RedPixels[13][15:11] = car_move_array_FR_BRoad_RLane[1][13:9];
			RedPixels[13][8:0]   = {car_move_array_FR_BRoad_RLane[1][6:0], 2'b11};
			
			if (show_Pass_Top_Turn_Car_RLane_Crash) begin
				RedPixels[12][10:9] = car_move_array_FR_TRoad_LLane_V[05];  
		      RedPixels[13][10:9] = car_move_array_FR_TRoad_LLane_V[06];  
			end
			else if (show_Crash_Top_Turn_Car_RLane_Crash) begin
				RedPixels[12][10:9] = 2'b11;
				RedPixels[13][10:9] = 2'b11;
			end
			else begin
				RedPixels[12][10:9] = car_move_array_FR_BRoad_RLane[0][8:7];
				RedPixels[13][10:9] = car_move_array_FR_BRoad_RLane[1][8:7];
			end
			/* ================================================================================ */
		   RedPixels[14] = 16'b0011111100000000;
		   RedPixels[15] = 16'b0011111100000000;			
			
			
			
			GrnPixels[00] = 16'b0000000000000000;
		   GrnPixels[01] = 16'b0000000000000000;
			
        // SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
        /* ================================================================================ */
			GrnPixels[02][15:7] = {2'b11, car_move_array_FR_TRoad_RLane[0][13:7]};       
			GrnPixels[02][4:0]   = {car_move_array_FR_TRoad_RLane[0][4:0]}; 
			
			GrnPixels[03][15:7] = {2'b11, car_move_array_FR_TRoad_RLane[1][13:7]}; 
			GrnPixels[03][4:0]   = {car_move_array_FR_TRoad_RLane[1][4:0]};
			
			if (show_Pass_Bott_Turn_Car_RLane_Crash) begin
				GrnPixels[02][6:5] = car_move_array_FR_BRoad_LLane_V[00];  
		      GrnPixels[03][6:5] = car_move_array_FR_BRoad_LLane_V[01];  
			end
			else if (show_Crash_Bott_Turn_Car_RLane_Crash) begin
				GrnPixels[02][6:5] = 2'b11;
				GrnPixels[03][6:5] = 2'b11;
			end
			else begin
				GrnPixels[02][6:5] = car_move_array_FR_TRoad_RLane[0][6:5];
				GrnPixels[03][6:5] = car_move_array_FR_TRoad_RLane[1][6:5];
			end				
			/* ================================================================================ */
			
		
		   GrnPixels[04] = {9'b110000000, car_move_array_FR_BRoad_LLane_V[02],5'b00000};
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			GrnPixels[05][15:7] = {5'b11000, car_move_array_FR_TRoad_LLane_H[0][10:7]};        
			GrnPixels[05][4:0]   = {car_move_array_FR_TRoad_LLane_H[0][4:0]}; 
			
			GrnPixels[06][15:7] = {5'b11000, car_move_array_FR_TRoad_LLane_H[1][10:7]};
			GrnPixels[06][4:0]   = {car_move_array_FR_TRoad_LLane_H[1][4:0]};
			
			if (show_Pass_Top_Turn_Car_LLane_Crash) begin
				GrnPixels[05][6:5] = car_move_array_FR_BRoad_LLane_V[03];  
		      GrnPixels[06][6:5] = car_move_array_FR_BRoad_LLane_V[04];  
			end
			else if (show_Crash_Top_Turn_Car_LLane_Crash) begin
				GrnPixels[05][6:5] = 2'b11;
				GrnPixels[06][6:5] = 2'b11;
			end
			else begin
				GrnPixels[05][6:5] = car_move_array_FR_TRoad_LLane_H[0][5:4];
				GrnPixels[06][6:5] = car_move_array_FR_TRoad_LLane_H[1][5:4];
			end				
		   /* ================================================================================ */
			
			
		   GrnPixels[07] = {5'b11000, car_move_array_FR_TRoad_LLane_V[00],2'b00, car_move_array_FR_BRoad_LLane_V[05], 5'b00000};
			
			GrnPixels[08] = {5'b00000, car_move_array_FR_TRoad_LLane_V[01], 2'b00, car_move_array_FR_BRoad_LLane_V[06], 5'b00011};
			
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			GrnPixels[09][15:11] = car_move_array_FR_BRoad_LLane_H[1][10:6];        
			GrnPixels[09][8:0]   = {car_move_array_FR_BRoad_LLane_H[1][3:0], 5'b00011}; 
			
			GrnPixels[10][15:11] = car_move_array_FR_BRoad_LLane_H[0][10:6];
			GrnPixels[10][8:0]   = {car_move_array_FR_BRoad_LLane_H[0][3:0], 5'b00011};
			
			if (show_Pass_Top_Turn_Car_LLane_Crash) begin
				GrnPixels[09][10:9] = car_move_array_FR_TRoad_LLane_V[02];  
		      GrnPixels[10][10:9] = car_move_array_FR_TRoad_LLane_V[03];  
			end
			else if (show_Crash_Top_Turn_Car_LLane_Crash) begin
				GrnPixels[09][10:9] = 2'b00;
				GrnPixels[10][10:9] = 2'b00;
			end
			else begin
				GrnPixels[09][10:9] = car_move_array_FR_BRoad_LLane_H[1][5:4];
				GrnPixels[10][10:9] = car_move_array_FR_BRoad_LLane_H[0][5:4];
			end			
			/* ================================================================================ */
			
			
		   GrnPixels[11] = {5'b00000, car_move_array_FR_TRoad_LLane_V[04], 9'b000000011};
			
			
			// SPLITS UP CODE FOR COLLISION CASES AND TURNING CARS
			/* ================================================================================ */
			GrnPixels[12][15:11] = car_move_array_FR_BRoad_RLane[0][13:9];        
			GrnPixels[12][8:0]   = {car_move_array_FR_BRoad_RLane[0][6:0], 2'b11};
			
			GrnPixels[13][15:11] = car_move_array_FR_BRoad_RLane[1][13:9];
			GrnPixels[13][8:0]   = {car_move_array_FR_BRoad_RLane[1][6:0], 2'b11};
			
			if (show_Pass_Top_Turn_Car_RLane_Crash) begin
				GrnPixels[12][10:9] = car_move_array_FR_TRoad_LLane_V[05];  
		      GrnPixels[13][10:9] = car_move_array_FR_TRoad_LLane_V[06];  
			end
			else if (show_Crash_Top_Turn_Car_RLane_Crash) begin
				GrnPixels[12][10:9] = 2'b00;
				GrnPixels[13][10:9] = 2'b00;
			end
			else begin
				GrnPixels[12][10:9] = car_move_array_FR_BRoad_RLane[0][8:7];
				GrnPixels[13][10:9] = car_move_array_FR_BRoad_RLane[1][8:7];
			end
			/* ================================================================================ */
			
		   GrnPixels[14] = 16'b0000000000000000;
		   GrnPixels[15] = 16'b0000000000000000;
			
		 end
	end


endmodule



module LED_Traffic_Light_tb();
	
	logic clk_traffic, reset, highW_G_farm_R_i, highW_Y_farm_R_i, highW_R_farm_G_i, highW_R_farm_Y_i, 
	      add_car_to_FR_TRoad_RLane_i, add_car_to_FR_BRoad_RLane_i, add_car_to_FR_BRoad_LLane_Turn_i, add_car_to_FR_TRoad_LLane_Turn_i;
	logic [4:0] traffic_Level_SWs_i;
   logic [15:0][15:0] RedPixels; // 16x16 array of red LEDs
   logic [15:0][15:0] GrnPixels; // 16x16 array of green LEDs
	logic [3:0] car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_BRoad_RLane, 
	                   car_queue_counter_FR_TRoad_LLane, car_queue_counter_FR_BRoad_LLane;						 
	logic [3:0] master_Collision_Counter;

	LED_Traffic_Light dut (clk_traffic, reset, traffic_Level_SWs_i, add_car_to_FR_TRoad_RLane_i, add_car_to_FR_BRoad_RLane_i,
                         add_car_to_FR_BRoad_LLane_Turn_i, add_car_to_FR_TRoad_LLane_Turn_i, 
                         highW_G_farm_R_i, highW_Y_farm_R_i, highW_R_farm_G_i, highW_R_farm_Y_i, 
								 RedPixels, GrnPixels, car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_BRoad_RLane,
								 car_queue_counter_FR_TRoad_LLane, car_queue_counter_FR_BRoad_LLane,
								 master_Collision_Counter);

	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk_traffic <= 0;
		forever #(CLOCK_PERIOD / 2) clk_traffic <= ~clk_traffic;
	end

	integer i;
	initial begin
		
		reset <= 1;
		highW_G_farm_R_i <= 0; highW_Y_farm_R_i <= 0; highW_R_farm_G_i <= 0; highW_R_farm_Y_i <= 0; 
		add_car_to_FR_TRoad_RLane_i <= 0; add_car_to_FR_BRoad_RLane_i <= 0; add_car_to_FR_BRoad_LLane_Turn_i <= 0; add_car_to_FR_TRoad_LLane_Turn_i <= 0; 
		traffic_Level_SWs_i <= 0;
		@(posedge clk_traffic);
		
		reset <= 0;
		highW_G_farm_R_i <= 1; highW_Y_farm_R_i <= 0; highW_R_farm_G_i <= 0; highW_R_farm_Y_i <= 0; 
		add_car_to_FR_TRoad_RLane_i <= 0; add_car_to_FR_BRoad_RLane_i <= 0; add_car_to_FR_BRoad_LLane_Turn_i <= 0; add_car_to_FR_TRoad_LLane_Turn_i <= 0; 
		traffic_Level_SWs_i <= 25;
		repeat(20) @(posedge clk_traffic);
		
		
		highW_G_farm_R_i <= 0; highW_Y_farm_R_i <= 1; highW_R_farm_G_i <= 0; highW_R_farm_Y_i <= 0; 
		traffic_Level_SWs_i <= 30;
		repeat(10) @(posedge clk_traffic);
		
		for (i = 0; i < 4; i++) begin
			add_car_to_FR_TRoad_RLane_i <= 1; add_car_to_FR_BRoad_RLane_i <= 1; add_car_to_FR_BRoad_LLane_Turn_i <= 1; add_car_to_FR_TRoad_LLane_Turn_i <= 1; 
			add_car_to_FR_TRoad_RLane_i <= 0; add_car_to_FR_BRoad_RLane_i <= 0; add_car_to_FR_BRoad_LLane_Turn_i <= 0; add_car_to_FR_TRoad_LLane_Turn_i <= 0; 
			@(posedge clk_traffic);
		end

		highW_G_farm_R_i <= 0; highW_Y_farm_R_i <= 0; highW_R_farm_G_i <= 1; highW_R_farm_Y_i <= 0; 
		traffic_Level_SWs_i <= 30;
		repeat(30) @(posedge clk_traffic);
		
		highW_G_farm_R_i <= 0; highW_Y_farm_R_i <= 0; highW_R_farm_G_i <= 0; highW_R_farm_Y_i <= 1; 
		traffic_Level_SWs_i <= 30;
		repeat(10) @(posedge clk_traffic);
		
		highW_G_farm_R_i <= 1; highW_Y_farm_R_i <= 0; highW_R_farm_G_i <= 0; highW_R_farm_Y_i <= 0; 
		add_car_to_FR_TRoad_RLane_i <= 0; add_car_to_FR_BRoad_RLane_i <= 0; add_car_to_FR_BRoad_LLane_Turn_i <= 0; add_car_to_FR_TRoad_LLane_Turn_i <= 0; 
		traffic_Level_SWs_i <= 25;
		repeat(20) @(posedge clk_traffic);
		
		$stop;
	end
	
endmodule

