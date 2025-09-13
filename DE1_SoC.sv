



// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT : Traffic Light Simulator/Controller

// DISCRIPTION: THIS TOP-LEVEL MODULE IS MEANT TO SIMULATE A 4-WAY TRAFFIC INTERSECTION. IN THIS DESIGN
//              EXISTS THE HIGHWAY (HW) ROADS THAT RUN VERTICALLY AND THE FARM ROADS (FR) THAT RUN HORIZONTIALLY. 
//              THIS DESIGN USES A 16X16 LED MATRIX TO VISUALLY DISPLAY THE MOVEMENT OF CARS. THE HW CARS THAT
//              TRAVEL FROM TOP TO BOTTOM ARE PLACED ON THE LEFT SIDE OF THE MATRIX, AND THE CARS THAT TRAVEL 
//              FROM BOTTOM TO TOP ARE PLACED ON THE RIGHT SIDE. THESE TWO MAIN HW ROADS RUNNING IN OPPOSITE 
//              DIRECTION CONTAIN TWO LANES. THE FARM ROAD CARS THAT TRAVEL FROM RIGHT TO LEFT ARE PLACED ON THE
//              TOP PORTION OF THE MATRIX AND THE CARS TRAVELING FROM LEFT TO RIGHT ARE PLACED ON THE BOTTOM.
//              THE FARM ROADS ALSO CARRY TWO LANES. THE RIGHT LANE FOR EACH FARM ROAD CAN ONLY TRAVEL STRIGHT.
//              THE LEFT LANE FOR EACH FARM ROAD CAN ONLY TURN LEFT.

// INPUTS: 
//        - KEY[0] = RESET
//        - KEY[1] & ~SW[9] = ADDING A CAR TO THE RIGHT LANE OF THE TOP FARM ROAD (CAN ONLY TRAVEL STRAIGHT FROM RIGHT TO LEFT ON THE MATRIX)   
//        - KEY[3] & ~SW[9] = ADDING A CAR TO THE RIGHT LANE OF THE BOTTOM FARM ROAD (CAN ONLY TRAVEL STRAIGHT FROM LEFT TO RIGHT ON THE MATRIX)
//        - KEY[1] & SW[9]  = ADDING A CAR TO THE LEFT TURNNING LANE OF THE TOP FARM ROAD (TRAVELS FROM RIGHT TO LEFT ON THE MATRIX, THEN TURNS LEFT AND TRAVLES DOWNWARD) 
//        - KEY[3] & SW[9]  = ADDING A CAR TO THE LEFT TURNNING LANE OF THE BOTTOM FARM ROAD (TRAVELS FROM LEFT TO RIGHT ON THE MATRIX, THEN TURNS LEFT AND TRAVLES UPWARD)
//        - SWITCHES [4:0]  = CHANGING THE TRAFFIC LEVEL (GROWS FROM LEVEL 0 (NO TRAFFIC) TO LEVEL 31 (HIGH TRAFFIC))
  
  
// OUTPUTS:
//        - ALL GPIO [35:0], CONNECTED TO THE LED MATRIX TO CONTROL THE DISPLAY
//        - HEX5 = DISPLAYS FROM 0-15 THE NUMBER OF CARS WAITING IN THE BOTTOM FR LEFT LANE TURN QUEUE 
//        - HEX4 = DISPLAYS FROM 0-15 THE NUMBER OF CARS WAITING IN THE BOTTOM FR RIGHT LANE STRAIGHT QUEUE 
//        - HEX3 = DISPLAYS THE LETTER C FOR COLLISIONS
//        - HEX2 = DISPLAYS FROM 0-15 THE NUMBER OF COLLISIONS THAT HAVE OCCURED
//        - HEX1 = DISPLAYS FROM 0-15 THE NUMBER OF CARS WAITING IN THE TOP FR RIGHT LANE STRAIGHT QUEUE  
//        - HEX0 = DISPLAYS FROM 0-15 THE NUMBER OF CARS WAITING IN THE TOP FR LEFT LANE TURN QUEUE 
  
// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
   output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0]  LEDR;
   input  logic [3:0]  KEY;
   input  logic [9:0]  SW;
   output logic [35:0] GPIO_1;
   input logic CLOCK_50;
	 
	
	/* =========================================== SYSTEM INTERFACE SIGNALS =========================================== */
	/* ================================================================================================================ */
	logic [31:0] clk;
	logic SYSTEM_CLOCK, TRAFFIC_CLOCK, reset, car_sensor;
	logic highW_G_farm_R, highW_Y_farm_R, highW_R_farm_G, highW_R_farm_Y;
	logic [15:0][15:0]RedPixels;
   logic [15:0][15:0]GrnPixels;
	logic [4:0] traffic_Level_SWs;	
	logic [3:0] car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_BRoad_RLane, car_queue_counter_FR_TRoad_LLane, car_queue_counter_FR_BRoad_LLane;
	logic add_car_FR_Top_Road_RLane, add_car_to_FR_BRoad_RLane, add_car_FR_Top_Road_LLane_Turn, add_car_to_FR_BRoad_LLane_Turn;
	logic [3:0] master_Collision_Counter;
	/* ================================================================================================================ */
	 
	
	/* ======================== INPUT CONTROL SIGNALS ======================== */
	/* ======================================================================= */
	assign reset = ~KEY[0];
	assign add_car_FR_Top_Road_RLane = ~KEY[1] & ~SW[9];
	assign add_car_to_FR_BRoad_RLane = ~KEY[3] & ~SW[9];	
	assign add_car_FR_Top_Road_LLane_Turn = ~KEY[1] & SW[9];
	assign add_car_to_FR_BRoad_LLane_Turn = ~KEY[3] & SW[9];
	assign traffic_Level_SWs = SW[4:0];
	/* ======================================================================= */

	
	// WILL TRIGGER THE CAR SENSOR IF ANY OF THE FARM ROAD LANES QUEUES ARE GREATER THEN 0
	assign car_sensor = (car_queue_counter_FR_TRoad_RLane > 0) || (car_queue_counter_FR_BRoad_RLane > 0) || (car_queue_counter_FR_TRoad_LLane > 0) || (car_queue_counter_FR_BRoad_LLane > 0);
	
	
	// INPUTS:
	//        - 50 MHz CLOCK
	//        - RESET
	// OUTPUTS:
	//        - 32-BIT REGISTER WITH DIVIDED 50MHz CLOCK. EX] clk[0] = 50MHz, clk[1] = 25MHz
	clock_divider divider (.clock(CLOCK_50), .reset(reset), .divided_clocks(clk));
	 
	 /* ================== TIMING VALUES FOR BOARD ================== */
//	parameter GREEN_LIGHT_TIMER_SET = 13 * 1525;
//	parameter YELLOW_LIGHT_TIMER_SET = 7 * 1525;
//	assign SYSTEM_CLOCK = clk[14]; // 1525 Hz clock signal
//	assign TRAFFIC_CLOCK = clk[23]; // 5.9 Hz clock signal
	
	 /* ================== TIMING VALUES FOR SIMULATION ================== */
     parameter GREEN_LIGHT_TIMER_SET = 13;
     parameter YELLOW_LIGHT_TIMER_SET = 7;
     assign SYSTEM_CLOCK = CLOCK_50; 
     assign TRAFFIC_CLOCK = CLOCK_50; 
	 

	// DISCRIPTION: CONTROLS THE STATE LOGIC OF THE TRAFFIC LIGHT STATES	 
	trafficL_ctrl_timer_wrapper #(GREEN_LIGHT_TIMER_SET, YELLOW_LIGHT_TIMER_SET) CTRL_TIMER (.clk(SYSTEM_CLOCK), .reset(reset), .sensor_i(car_sensor), 
											.highW_G_farm_R_o(highW_G_farm_R), .highW_Y_farm_R_o(highW_Y_farm_R), .highW_R_farm_G_o(highW_R_farm_G), 
											.highW_R_farm_Y_o(highW_R_farm_Y));

											
	// DISCRIPTION: DRIVER FOR LED MATRIX	 
	LEDDriver LED_Dr(.CLK(SYSTEM_CLOCK), .RST(reset), .EnableCount(1'b1), .RedPixels(RedPixels), .GrnPixels(GrnPixels), .GPIO_1(GPIO_1));

	
	// DISCRIPTION: MANAGES CAR QUEUES, MOVMENTS/ANIMATIONS ON THE MATRIX, AND COLLISIONS DETECTED
	LED_Traffic_Light LED_Trraffic_L (.clk_traffic(TRAFFIC_CLOCK), .reset(reset), .traffic_Level_SWs_i(traffic_Level_SWs), 
	                                  .add_car_to_FR_TRoad_RLane_i(add_car_FR_Top_Road_RLane), .add_car_to_FR_BRoad_RLane_i(add_car_to_FR_BRoad_RLane),
												 .add_car_to_FR_BRoad_LLane_Turn_i(add_car_to_FR_BRoad_LLane_Turn), .add_car_to_FR_TRoad_LLane_Turn_i(add_car_FR_Top_Road_LLane_Turn),
											    .highW_G_farm_R_i(highW_G_farm_R), 
												 .highW_Y_farm_R_i(highW_Y_farm_R), .highW_R_farm_G_i(highW_R_farm_G), .highW_R_farm_Y_i(highW_R_farm_Y), 
												 .RedPixels(RedPixels), .GrnPixels(GrnPixels), .car_queue_counter_FR_TRoad_RLane(car_queue_counter_FR_TRoad_RLane),
												 .car_queue_counter_FR_BRoad_RLane(car_queue_counter_FR_BRoad_RLane),
												 .car_queue_counter_FR_TRoad_LLane(car_queue_counter_FR_TRoad_LLane), .car_queue_counter_FR_BRoad_LLane(car_queue_counter_FR_BRoad_LLane),
												 . master_Collision_Counter(master_Collision_Counter));
												 												 

	// DISCRPTION: DISPLAYS THE CAR LANE QUEUE COUNTER VALUES, AND THE NUMBER OF COLLISIONS											 
	HEX_Display HEX (.car_queue_counter_FR_TRoad_RLane(car_queue_counter_FR_TRoad_RLane), .car_queue_counter_FR_TRoad_LLane(car_queue_counter_FR_TRoad_LLane), 
						  .car_queue_counter_FR_BRoad_RLane(car_queue_counter_FR_BRoad_RLane), .car_queue_counter_FR_BRoad_LLane(car_queue_counter_FR_BRoad_LLane),
						  .master_Collision_Counter(master_Collision_Counter),
						  .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0));
	 
endmodule



module DE1_SoC_tb();

	logic CLOCK_50;
	logic [9:0] SW;
	logic [3:0] KEY;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [35:0] GPIO_1;
	logic reset;
	logic [4:0] traffic_Level_SWs;
	logic add_car_FR_Top_Road, turnSW, add_car_FR_Bot_Road;
	
	assign KEY[0] = ~reset;
	assign SW[4:0] = traffic_Level_SWs;
	assign SW[9] = turnSW;
	assign KEY[1] = ~add_car_FR_Top_Road;
	assign KEY[3] = ~add_car_FR_Bot_Road;
	
	
	DE1_SoC dut (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	integer i;
	initial begin
		
		reset <= 1; traffic_Level_SWs <= 0; turnSW <= 0; add_car_FR_Top_Road <= 0; add_car_FR_Bot_Road <= 0; repeat(4)  @(posedge CLOCK_50);
		for (i = 0; i < 32; i++) begin
			reset <= 0; traffic_Level_SWs <= i; turnSW <= 0; add_car_FR_Top_Road <= 0; add_car_FR_Bot_Road <= 0;  repeat(10) @(posedge CLOCK_50);
		end
		
		/* ========================================= ADD STRAIGHT CAR IN TOP FARM ROAD ========================================= */
		for (i = 0; i < 5; i++) begin
			reset <= 0; traffic_Level_SWs <= 25; turnSW <= 0; add_car_FR_Top_Road <= 1; add_car_FR_Bot_Road <= 1;  @(posedge CLOCK_50);
			reset <= 0; traffic_Level_SWs <= 25; turnSW <= 0; add_car_FR_Top_Road <= 0; add_car_FR_Bot_Road <= 0;  @(posedge CLOCK_50);
		end
	

	   /* ========================================= ADD TURNING CAR IN BOTTOM FARM ROAD ========================================= */
		for (i = 0; i < 5; i++) begin
			reset <= 0; traffic_Level_SWs <= 25; turnSW <= 1; add_car_FR_Top_Road <= 1; add_car_FR_Bot_Road <= 1;  @(posedge CLOCK_50);
			reset <= 0; traffic_Level_SWs <= 25; turnSW <= 1; add_car_FR_Top_Road <= 0; add_car_FR_Bot_Road <= 0;  @(posedge CLOCK_50);
		end	
		
		reset <= 0; traffic_Level_SWs <= 0; turnSW <= 0; add_car_FR_Top_Road <= 0; add_car_FR_Bot_Road <= 0; repeat(30)  @(posedge CLOCK_50);
		
		$stop;
	end


endmodule


