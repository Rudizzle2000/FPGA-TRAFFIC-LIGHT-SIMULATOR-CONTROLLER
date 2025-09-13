


// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Animates the left turning cars moving from bottom to top
module carFR_Turn_Animate_Bottom_To_Top (traffic_clk, reset, add_car, car_move_array_h, car_move_array_v, decrement_car);

	// Input signals
	input logic traffic_clk, reset, add_car;
	// Output signals
	output logic [1:0] [10:0] car_move_array_h; // Horizontal car movement array
	output logic [6:0] [1:0] car_move_array_v;  // Vertical car movement array
	output logic decrement_car; // Signal to decrement car position
	
	// Internal signals for horizontal movement
	logic initalize_H, add_car_state_H, space_H, shift_all_H;
	// Internal signals for vertical movement
	logic initalize_V, add_car_state_V, space_V, shift_all_V, turn_car, halve_car, end_car;
	
	// State machine for horizontal car movement
	enum {INITALIZE_H, READY_H, ADD_CAR_S1_H, ADD_CAR_S2_H, SPACE_H} ps_H, ns_H;
	
	// State machine logic for horizontal movement
	always_comb begin
		case(ps_H)
			INITALIZE_H: begin 
				ns_H = READY_H; // Initialize state for horizontal direction
			end
			READY_H: begin
				if (add_car) 
					ns_H = ADD_CAR_S1_H; // Transition to add car state
				else 
					ns_H = READY_H; // Stay in ready state
			end
			ADD_CAR_S1_H: begin
				ns_H = ADD_CAR_S2_H; // Transition to second add car state
			end
			ADD_CAR_S2_H: begin
				ns_H = SPACE_H; // Transition to space state
			end
			SPACE_H: begin
				ns_H = READY_H; // Return to ready state
			end
		endcase
	end
	
	// Assign control signals based on state
	assign initalize_H = (ps_H == INITALIZE_H);  // Initialize horizontal movement
	assign add_car_state_H = (ps_H == ADD_CAR_S2_H) || (ps_H == ADD_CAR_S1_H); // Adding car states
	assign space_H = (ps_H == SPACE_H); // Space state for horizontal movement
	assign shift_all_H = (ps_H != INITALIZE_H); // Shift all positions when not in initialization
	assign decrement_car = (ps_H == ADD_CAR_S1_H); // Decrement car position in horizontal direction when in ADD_CAR_S1_H state
	
	// State transition logic for horizontal direction
	always_ff @(posedge traffic_clk) begin
		if (reset) 
			ps_H <= INITALIZE_H; // Reset to initialization state
		else 
			ps_H <= ns_H; // Transition to next state
	end
	
	// Car movement logic for horizontal direction
	always_ff @(posedge traffic_clk) begin
		if (initalize_H) begin
			// Initialize horizontal car positions to 0
			car_move_array_h[0] <= 11'b0;
			car_move_array_h[1] <= 11'b0;
		end
		else if (add_car_state_H) begin
			// Add the car at the last column (10th column) when in ADD_CAR_S2_H state
			car_move_array_h[0][10] <= 1'b1; // First row, column 10
			car_move_array_h[1][10] <= 1'b1; // Second row, column 10
		end
		else if (space_H) begin
			// Clear the car position at the last column (10th column) when in SPACE_H state
			car_move_array_h[0][10] <= 1'b0; // First row, column 10
			car_move_array_h[1][10] <= 1'b0; // Second row, column 10
		end
		
		if (shift_all_H) begin
			// Shift the car positions horizontally to the left from column 10 to column 1
			car_move_array_h[0][9] <= car_move_array_h[0][10];
			car_move_array_h[1][9] <= car_move_array_h[1][10];
			// Repeat for all columns from 9 to 1
			car_move_array_h[0][8] <= car_move_array_h[0][9];
			car_move_array_h[1][8] <= car_move_array_h[1][9];
			// Continue shifting until column 1
			car_move_array_h[0][7] <= car_move_array_h[0][8];
			car_move_array_h[1][7] <= car_move_array_h[1][8];
			car_move_array_h[0][6] <= car_move_array_h[0][7];
			car_move_array_h[1][6] <= car_move_array_h[1][7];
			car_move_array_h[0][5] <= car_move_array_h[0][6];
			car_move_array_h[1][5] <= car_move_array_h[1][6];
			car_move_array_h[0][4] <= car_move_array_h[0][5];
			car_move_array_h[1][4] <= car_move_array_h[1][5];
			car_move_array_h[0][3] <= car_move_array_h[0][4];
			car_move_array_h[1][3] <= car_move_array_h[1][4];
			car_move_array_h[0][2] <= car_move_array_h[0][3];
			car_move_array_h[1][2] <= car_move_array_h[1][3];
			car_move_array_h[0][1] <= car_move_array_h[0][2];
			car_move_array_h[1][1] <= car_move_array_h[1][2];
			
			// Handle special cases for halving or ending the car
			if (halve_car) begin
				// Split the car when halved
				car_move_array_h[0][0] <= 0; 
				car_move_array_h[0][1] <= 0;
				car_move_array_h[1][0] <= 1; 
				car_move_array_h[1][1] <= 1;
			end
			else if (end_car) begin
				// End the car when it reaches the end
				car_move_array_h[0][0] <= 0; 
				car_move_array_h[0][1] <= 0;
				car_move_array_h[1][0] <= 0; 
				car_move_array_h[1][1] <= 0;
			end
			else begin
				// Continue shifting the car positions
				car_move_array_h[0][0] <= car_move_array_h[0][1];
				car_move_array_h[1][0] <= car_move_array_h[1][1];
			end
		end
	end	
	
	// State machine for vertical car movement
	enum {INITALIZE_V, READY_V, ADD_CAR_S1_V, ADD_CAR_S2_V, SPACE_V} ps_V, ns_V;
	
	// Assign conditions for turning, halving, or ending the car
	assign turn_car = (car_move_array_h[0][1] == 1) && (car_move_array_h[0][2] == 1);
	assign halve_car = (ps_V == ADD_CAR_S1_V); // Halve the car when in ADD_CAR_S1_V state
	assign end_car = (ps_V == ADD_CAR_S2_V); // End the car when in ADD_CAR_S2_V state
	
	// State machine logic for vertical movement
	always_comb begin
		case(ps_V)
			INITALIZE_V: begin 
				ns_V = READY_V; // Initialize state for vertical direction
			end
			READY_V: begin
				if (turn_car) 
					ns_V = ADD_CAR_S1_V; // Transition to add car state if car is turning
				else 
					ns_V = READY_V; // Stay in ready state
			end
			ADD_CAR_S1_V: begin
				ns_V = ADD_CAR_S2_V; // Transition to second add car state
			end
			ADD_CAR_S2_V: begin
				ns_V = SPACE_V; // Transition to space state
			end
			SPACE_V: begin
				ns_V = READY_V; // Return to ready state
			end
		endcase
	end
	
	// Assign control signals based on state
	assign initalize_V = (ps_H == INITALIZE_V);  // Initialize vertical movement
	assign add_car_state_V = (ps_V == ADD_CAR_S2_V) || (ps_V == ADD_CAR_S1_V); // Adding car states
	assign space_V = (ps_V == SPACE_V); // Space state for vertical movement
	assign shift_all_V = (ps_V != INITALIZE_V); // Shift all positions when not in initialization
	
	// State transition logic for vertical direction
	always_ff @(posedge traffic_clk) begin
		if (reset) 
			ps_V <= INITALIZE_V; // Reset to initialization state
		else 
			ps_V <= ns_V; // Transition to next state
	end
	
	// Car movement logic for vertical direction
	always_ff @(posedge traffic_clk) begin
		if (initalize_V) begin
			// Initialize vertical car positions to 0
			car_move_array_v <= 7'b0;
		end
		else if (add_car_state_V) begin
			// Add the car at position 6 (second-to-last position) when in ADD_CAR_S2_V state
			car_move_array_v[06] <= 2'b11; // Position 6, add car
		end
		else if (space_V) begin
			// Clear the car position at position 6 when in SPACE_V state
			car_move_array_v[06] <= 2'b00; // Position 6, clear car
		end
		
		if (shift_all_V) begin
			// Shift the car positions vertically upward from position 6 to position 0
			car_move_array_v[05] <= car_move_array_v[06];
			car_move_array_v[04] <= car_move_array_v[05];
			car_move_array_v[03] <= car_move_array_v[04];
			car_move_array_v[02] <= car_move_array_v[03];
			car_move_array_v[01] <= car_move_array_v[02];
			car_move_array_v[00] <= car_move_array_v[01];
		end
	end

endmodule

// Testbench for the module
module carFR_Turn_Animate_Bottom_To_Top_tb();
	logic traffic_clk, reset, add_car;
	logic [1:0] [10:0] car_move_array_h;
	logic [6:0] [1:0] car_move_array_v;
	logic decrement_car;
	
	// Instantiate the carFR_Turn_Animate_Bottom_To_Top module for testing
	carFR_Turn_Animate_Bottom_To_Top dut (traffic_clk, reset, add_car, car_move_array_h, car_move_array_v, decrement_car);

	// Clock period for simulation
	parameter CLOCK_PERIOD = 100;
	
	// Generate a clock signal for testing
	initial begin
		traffic_clk <= 0;
		forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;
	end

	// Testbench logic to apply signals and observe behavior
	initial begin
		reset <= 1; add_car <= 0; repeat(4)  @(posedge traffic_clk);
		reset <= 0; add_car <= 0; repeat(4)  @(posedge traffic_clk);
		reset <= 0; add_car <= 1;            @(posedge traffic_clk);
		reset <= 0; add_car <= 0; repeat(24) @(posedge traffic_clk);
		reset <= 0; add_car <= 1; repeat(40) @(posedge traffic_clk);
		reset <= 0; add_car <= 0; repeat(10) @(posedge traffic_clk);
	
		$stop; // Stop the simulation
	end

endmodule

