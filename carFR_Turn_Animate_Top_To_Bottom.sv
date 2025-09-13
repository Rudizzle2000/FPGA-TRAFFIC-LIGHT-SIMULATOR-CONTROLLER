


// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Animates the left turning cars moving from top to bottom
module carFR_Turn_Animate_Top_To_Bottom (traffic_clk, reset, add_car, car_move_array_h, car_move_array_v, decrement_car);

	// Input signals
	input logic traffic_clk, reset, add_car;
	// Output signals
	output logic [1:0] [10:0] car_move_array_h; // Horizontal movement array for the cars
	output logic [7:0] [1:0] car_move_array_v;  // Vertical movement array for the cars
	output logic decrement_car; // Signal to decrement the car position
	
	// Internal signals for horizontal movement
	logic initalize_H, add_car_state_H, space_H, shift_all_H;
	// Internal signals for vertical movement
	logic initalize_V, add_car_state_V, space_V, shift_all_V, turn_car, halve_car, end_car;
	
	// State machine for horizontal car movement
	enum {INITALIZE_H, READY_H, ADD_CAR_S1_H, ADD_CAR_S2_H, SPACE_H} ps_H, ns_H;
	
	// State machine logic for horizontal movement
	always_comb begin
		case(ps_H)
			INITALIZE_H: ns_H = READY_H; // Initialize state
			READY_H: 
				if (add_car) 
					ns_H = ADD_CAR_S1_H; // Transition to add car state
				else 
					ns_H = READY_H; // Stay in ready state
			ADD_CAR_S1_H: ns_H = ADD_CAR_S2_H; // Transition to second add car state
			ADD_CAR_S2_H: ns_H = SPACE_H; // Transition to space state
			SPACE_H: ns_H = READY_H; // Return to ready state
		endcase
	end
	
	// Assign signals based on state
	assign initalize_H = (ps_H == INITALIZE_H);  // Initializing horizontal car position
	assign add_car_state_H = (ps_H == ADD_CAR_S2_H) || (ps_H == ADD_CAR_S1_H); // Adding car states
	assign space_H = (ps_H == SPACE_H); // Space state for horizontal movement
	assign shift_all_H = (ps_H != INITALIZE_H); // Shifting all positions
	assign decrement_car = (ps_H == ADD_CAR_S1_H); // Signal to decrement car position in horizontal direction
	
	// Flip-flop for state transitions on the rising edge of the clock
	always_ff @(posedge traffic_clk) begin
		if (reset) 
			ps_H <= INITALIZE_H; // Reset state
		else 
			ps_H <= ns_H; // Transition to next state
	end
	
	// Car movement logic for horizontal direction
	always_ff @(posedge traffic_clk) begin
		if (initalize_H) begin
			// Initialize horizontal car array positions to 0
			car_move_array_h[0] <= 11'b0;
			car_move_array_h[1] <= 11'b0;
		end
		else if (add_car_state_H) begin
			// Set the first column of car positions when adding a car
			car_move_array_h[0][0] <= 1'b1;
			car_move_array_h[1][0] <= 1'b1;
		end
		else if (space_H) begin
			// Reset the first column when in space state
			car_move_array_h[0][0] <= 1'b0;
			car_move_array_h[1][0] <= 1'b0;
		end
		
		if (shift_all_H) begin
			// Shift the car positions in horizontal direction to the next column
			// from column 0 to column 10 for both rows
			car_move_array_h[0][1] <= car_move_array_h[0][0];
			car_move_array_h[1][1] <= car_move_array_h[1][0];
			// Repeat the same for each column till 9
			car_move_array_h[0][2] <= car_move_array_h[0][1];
			car_move_array_h[1][2] <= car_move_array_h[1][1];
			car_move_array_h[0][3] <= car_move_array_h[0][2];
			car_move_array_h[1][3] <= car_move_array_h[1][2];
			car_move_array_h[0][4] <= car_move_array_h[0][3];
			car_move_array_h[1][4] <= car_move_array_h[1][3];
			car_move_array_h[0][5] <= car_move_array_h[0][4];
			car_move_array_h[1][5] <= car_move_array_h[1][4];
			car_move_array_h[0][6] <= car_move_array_h[0][5];
			car_move_array_h[1][6] <= car_move_array_h[1][5];
			car_move_array_h[0][7] <= car_move_array_h[0][6];
			car_move_array_h[1][7] <= car_move_array_h[1][6];
			car_move_array_h[0][8] <= car_move_array_h[0][7];
			car_move_array_h[1][8] <= car_move_array_h[1][7];
			car_move_array_h[0][9] <= car_move_array_h[0][8];
			car_move_array_h[1][9] <= car_move_array_h[1][8];
			
			// Handle car split or end conditions
			if (halve_car) begin
				// Move the car from the 10th column to the 9th column in horizontal direction
				car_move_array_h[0][10] <= 0; 
				car_move_array_h[0][9] <= 0;
				car_move_array_h[1][10] <= 1;
				car_move_array_h[1][9] <= 1;
			end
			else if (end_car) begin
				// End the car by resetting the last two columns
				car_move_array_h[0][10] <= 0; 
				car_move_array_h[0][9] <= 0;
				car_move_array_h[1][10] <= 0; 
				car_move_array_h[1][9] <= 0;
			end
			else begin
				// Continue shifting the car positions
				car_move_array_h[0][10] <= car_move_array_h[0][9];
				car_move_array_h[1][10] <= car_move_array_h[1][9];
			end
		end
	end	
	
	// State machine for vertical car movement
	enum {INITALIZE_V, READY_V, ADD_CAR_S1_V, ADD_CAR_S2_V, SPACE_V} ps_V, ns_V;
	
	// Check if the car is in the turning condition
	assign turn_car = (car_move_array_h[0][9] == 1) && (car_move_array_h[0][8] == 1);
	assign halve_car = (ps_V == ADD_CAR_S1_V); // Halve the car when in this state
	assign end_car = (ps_V == ADD_CAR_S2_V); // End the car in this state

	// State machine logic for vertical movement
	always_comb begin
		case(ps_V)
			INITALIZE_V: ns_V = READY_V; // Initialize state for vertical direction
			READY_V: 
				if (turn_car) 
					ns_V = ADD_CAR_S1_V; // Start moving vertically if car turns
				else 
					ns_V = READY_V; // Stay in ready state
			ADD_CAR_S1_V: ns_V = ADD_CAR_S2_V; // Transition to second add car state
			ADD_CAR_S2_V: ns_V = SPACE_V; // Transition to space state
			SPACE_V: ns_V = READY_V; // Return to ready state
		endcase
	end
	
	// Assign signals based on state
	assign initalize_V = (ps_V == INITALIZE_V);  // Initialize vertical car position
	assign add_car_state_V = (ps_V == ADD_CAR_S2_V) || (ps_V == ADD_CAR_S1_V); // Adding car states
	assign space_V = (ps_V == SPACE_V); // Space state for vertical movement
	assign shift_all_V = (ps_V != INITALIZE_V); // Shifting all positions vertically
	
	// Flip-flop for state transitions on the rising edge of the clock
	always_ff @(posedge traffic_clk) begin
		if (reset) 
			ps_V <= INITALIZE_V; // Reset vertical state
		else 
			ps_V <= ns_V; // Transition to next vertical state
	end
	
	// Car movement logic for vertical direction
	always_ff @(posedge traffic_clk) begin
		if (initalize_V) begin
			// Initialize vertical car array positions to 0
			car_move_array_v <= 8'b0;
		end
		else if (add_car_state_V) begin
			// Add the car at the first position in vertical direction
			car_move_array_v[00] <= 2'b11;
		end
		else if (space_V) begin
			// Reset the car position in space state
			car_move_array_v[00] <= 2'b00;
		end
		
		if (shift_all_V) begin
			// Shift the car positions vertically down from position 0 to 7
			car_move_array_v[01] <= car_move_array_v[00];
			car_move_array_v[02] <= car_move_array_v[01];
			car_move_array_v[03] <= car_move_array_v[02];
			car_move_array_v[04] <= car_move_array_v[03];
			car_move_array_v[05] <= car_move_array_v[04];
			car_move_array_v[06] <= car_move_array_v[05];
			car_move_array_v[07] <= car_move_array_v[06];
		end
	end

endmodule


module carFR_Turn_Animate_Top_To_Bottom_tb();

	logic traffic_clk, reset, add_car;
	logic [1:0] [10:0] car_move_array_h;
	logic [7:0] [1:0] car_move_array_v;
	logic decrement_car;
	
	// Instantiate the carFR_Turn_Animate_Top_To_Bottom module for testing
	carFR_Turn_Animate_Top_To_Bottom dut (traffic_clk, reset, add_car, car_move_array_h, car_move_array_v, decrement_car);

	parameter CLOCK_PERIOD = 100;
	
	// Generate a clock signal for testing
	initial begin
		traffic_clk <= 0;
		forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;
	end

	// Testbench to apply signals and observe behavior
	initial begin
		// Initial conditions with reset active and no cars added
		reset <= 1; add_car <= 0; repeat(4)  @(posedge traffic_clk);
		reset <= 0; add_car <= 0; repeat(4)  @(posedge traffic_clk);
		reset <= 0; add_car <= 1;            @(posedge traffic_clk); // Add a car
		reset <= 0; add_car <= 0; repeat(24) @(posedge traffic_clk);
		reset <= 0; add_car <= 1; repeat(40) @(posedge traffic_clk); // Add another car
		reset <= 0; add_car <= 0; repeat(10) @(posedge traffic_clk);
	
		$stop; // Stop simulation
	end

endmodule


