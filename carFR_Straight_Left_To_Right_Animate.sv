

// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Animates the straight traveling cars on the farm road moving from left to right
module carFR_Straight_Left_To_Right_Animate(traffic_clk, reset, add_car, car_move_array, decrement_car);

	// Input signals: 
	input logic traffic_clk, reset, add_car;
	
	// Output signals:
	output logic [1:0] [13:0] car_move_array; // 2D array for car positions
	output logic decrement_car; // Signal to decrement the car count
	
	// Internal signals:
	logic initalize, add_car_state, space, shift_all;
	
	// State machine definitions:
	enum {INITALIZE, READY, ADD_CAR_S1, ADD_CAR_S2, SPACE} ps, ns; // Define the states for the FSM

	// Next state logic:
	always_comb begin
		case(ps)
			// In the INITALIZE state, transition to READY state:
			INITALIZE: begin 
				ns = READY;
			end
							
			// In the READY state, wait for an add_car signal to transition to ADD_CAR_S1:
			READY: begin
				if (add_car) begin
					ns = ADD_CAR_S1;
				end
				else begin
					ns = READY;
				end
			end
		
			// ADD_CAR_S1 and ADD_CAR_S2 states for adding a car:
			ADD_CAR_S1: begin
				ns = ADD_CAR_S2;
			end
							
			ADD_CAR_S2: begin
				ns = SPACE;
			end
							
			// In SPACE state, transition back to READY:
			SPACE: begin
				ns = READY;
			end
	
		endcase
	end
	
	// Assign the internal states based on the current state:
	assign initalize = (ps == INITALIZE);  // If in the INITALIZE state
	assign add_car_state = (ps == ADD_CAR_S2) || (ps == ADD_CAR_S1);  // If in ADD_CAR states
	assign space = (ps == SPACE);  // If in the SPACE state
	assign shift_all = (ps != INITALIZE);  // If not in the INITALIZE state, shift positions
	assign decrement_car = (ps == ADD_CAR_S1);  // Decrement car when transitioning to ADD_CAR_S1
	
	// Flip-flop for updating the state on each clock cycle:
	always_ff @(posedge traffic_clk) begin
		if (reset) begin
			ps <= INITALIZE; // Reset state machine to INITALIZE
		end
		else begin
			ps <= ns; // Update to next state
		end
	end
	
	// Logic for controlling car positions based on state:
	always_ff @(posedge traffic_clk) begin
		if (initalize) begin
			// Initialize car positions to 0:
			car_move_array[0] <= 14'b0;
			car_move_array[1] <= 14'b0;
		end
		else if (add_car_state) begin
			// Add a car to the starting position (13th bit of the array):
			car_move_array[0][13] <= 1'b1;
			car_move_array[1][13] <= 1'b1;
		end
		else if (space) begin
			// Clear the cars from the starting position (13th bit of the array):
			car_move_array[0][13] <= 1'b0;
			car_move_array[1][13] <= 1'b0;
		end
		
		// Shift all cars in the array by one position to the right:
		if (shift_all) begin
			// Shift each car's position from 13th bit to the 12th, 11th, etc.
			car_move_array[0][12] <= car_move_array[0][13];
			car_move_array[1][12] <= car_move_array[1][13];
			
			car_move_array[0][11] <= car_move_array[0][12];
			car_move_array[1][11] <= car_move_array[1][12];
			
			car_move_array[0][10] <= car_move_array[0][11];
			car_move_array[1][10] <= car_move_array[1][11];
			
			car_move_array[0][9] <= car_move_array[0][10];
			car_move_array[1][9] <= car_move_array[1][10];
			
			car_move_array[0][8] <= car_move_array[0][9];
			car_move_array[1][8] <= car_move_array[1][9];
			
			car_move_array[0][7] <= car_move_array[0][8];
			car_move_array[1][7] <= car_move_array[1][8];
			
			car_move_array[0][6] <= car_move_array[0][7];
			car_move_array[1][6] <= car_move_array[1][7];
			
			car_move_array[0][5] <= car_move_array[0][6];
			car_move_array[1][5] <= car_move_array[1][6];
			
			car_move_array[0][4] <= car_move_array[0][5];
			car_move_array[1][4] <= car_move_array[1][5];
			
			car_move_array[0][3] <= car_move_array[0][4];
			car_move_array[1][3] <= car_move_array[1][4];
			
			car_move_array[0][2] <= car_move_array[0][3];
			car_move_array[1][2] <= car_move_array[1][3];
			
			car_move_array[0][1] <= car_move_array[0][2];
			car_move_array[1][1] <= car_move_array[1][2];
			
			car_move_array[0][0] <= car_move_array[0][1];
			car_move_array[1][0] <= car_move_array[1][1];
		end
	end

endmodule

// Testbench for carFR_Straight_Left_To_Right_Animate module:
module carFR_Straight_Left_To_Right_Animate_tb();

	// Testbench signals:
	logic traffic_clk, reset, add_car;
	logic [1:0] [13:0] car_move_array;
	logic decrement_car;
	
	// Instantiate the DUT (Device Under Test):
	carFR_Straight_Left_To_Right_Animate dut (traffic_clk, reset, add_car, car_move_array, decrement_car);

	parameter CLOCK_PERIOD = 100; // Define clock period

	// Generate traffic_clk signal with the defined clock period:
	initial begin
		traffic_clk <= 0;
		forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;
	end

	// Test sequence:
	initial begin
		// Apply reset and test adding cars:
		reset <= 1; add_car <= 0; repeat(4)  @(posedge traffic_clk);
		reset <= 0; add_car <= 0; repeat(4)  @(posedge traffic_clk);
		reset <= 0; add_car <= 1;            @(posedge traffic_clk);
		reset <= 0; add_car <= 0; repeat(20) @(posedge traffic_clk);
		reset <= 0; add_car <= 1; repeat(40) @(posedge traffic_clk);
		reset <= 0; add_car <= 0; repeat(10) @(posedge traffic_clk);
	
		// Stop simulation after the test:
		$stop;
	end

endmodule


