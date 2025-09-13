
// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Manages the logic for collisions and when to enable a turning car
module collision_Intersect (traffic_clk, reset, collision_Cases, turning_Car_Incoming, show_Pass, collision_Counter, show_Crash);

    // Input Signals
    input logic traffic_clk;               // Traffic system clock
    input logic reset;                     // System reset signal
    input logic collision_Cases;           // Indicates whether a collision case is detected
    input logic turning_Car_Incoming;      // Indicates whether a turning car is incoming

    // Output Signals
    output logic show_Pass;                // Signal to show a car can safely pass
    output logic [3:0] collision_Counter;  // 4-bit counter for collision occurrences
    output logic show_Crash;               // Signal to indicate a crash is in progress

    // Internal Signals
    logic pass_Turning_Car_Enable;         // Enables passing when there is no collision
    logic collision_Imminent;              // Indicates an imminent collision
    logic add_collsion;                    // Trigger for adding a collision to the counter

    // Derived Signals
    assign pass_Turning_Car_Enable = ~collision_Cases; // Passing enabled when no collision is detected
    assign collision_Imminent = collision_Cases;       // Imminent collision flag

    // Collision FSM States
    enum {READY_COLLISION, ADD_COLLISION_S1, ADD_COLLISION_S2} ps_COLL, ns_COLL;

    // Trigger for incrementing collision counter
    assign add_collsion = (ps_COLL == ADD_COLLISION_S2);

    // Collision FSM Next State Logic
    always_comb begin
        case (ps_COLL)
            READY_COLLISION: begin
                if (collision_Imminent)
                    ns_COLL = ADD_COLLISION_S1;  // Transition to add collision state
                else
                    ns_COLL = READY_COLLISION;  // Remain in ready state
            end
            ADD_COLLISION_S1:
                ns_COLL = ADD_COLLISION_S2;      // Move to the next step in collision addition
            ADD_COLLISION_S2:
                ns_COLL = READY_COLLISION;      // Return to ready state
        endcase
    end

    // Collision Counter Logic
    always_ff @(posedge traffic_clk) begin
        if (reset)
            collision_Counter <= 0;               // Reset the counter
        else if ((collision_Counter < 15) && add_collsion)
            collision_Counter <= collision_Counter + 4'b0001; // Increment counter
    end

    // Passing FSM States
    enum {DONT_PASS, CAR_PASS_READY, PASS_TURNING_CAR_S1, PASS_TURNING_CAR_S2, PASS_TURNING_CAR_S3} ps_PASS, ns_PASS;

    // Crash FSM States
    enum {READY_CRASH, CRASH_S1, CRASH_S2, CRASH_S3} ps_CRASH, ns_CRASH;

    // Derived Output Signal for Passing
    assign show_Pass = (ps_PASS == CAR_PASS_READY) || (ps_PASS == PASS_TURNING_CAR_S1) || 
                       (ps_PASS == PASS_TURNING_CAR_S2) || (ps_PASS == PASS_TURNING_CAR_S3);

    // Synchronous State Update
    always_ff @(posedge traffic_clk) begin
        if (reset) begin
            ps_PASS  <= DONT_PASS;          // Reset passing FSM
            ps_CRASH <= READY_CRASH;        // Reset crash FSM
            ps_COLL  <= READY_COLLISION;    // Reset collision FSM
        end else begin
            ps_PASS  <= ns_PASS;           // Update passing FSM state
            ps_CRASH <= ns_CRASH;          // Update crash FSM state
            ps_COLL  <= ns_COLL;           // Update collision FSM state
        end
    end

    // Passing FSM Next State Logic
    always_comb begin
        case (ps_PASS)
            DONT_PASS: begin
                if (turning_Car_Incoming && ~collision_Imminent)
                    ns_PASS = CAR_PASS_READY; // Car ready to pass
                else
                    ns_PASS = DONT_PASS;      // Remain in do-not-pass state
            end
            CAR_PASS_READY: begin
                if (~collision_Imminent)
                    ns_PASS = PASS_TURNING_CAR_S1; // Start passing
                else
                    ns_PASS = DONT_PASS;         // Abort passing
            end
            PASS_TURNING_CAR_S1:
                ns_PASS = PASS_TURNING_CAR_S2;   // Transition to next step in passing
            PASS_TURNING_CAR_S2:
                ns_PASS = PASS_TURNING_CAR_S3;   // Transition to next step in passing
            PASS_TURNING_CAR_S3: begin
                if (collision_Imminent || ~turning_Car_Incoming)
                    ns_PASS = DONT_PASS;         // Stop passing
                else
                    ns_PASS = CAR_PASS_READY;    // Restart passing
            end
        endcase
    end

    // Derived Output Signal for Crash
    assign show_Crash = (ps_CRASH == CRASH_S1) || (ps_CRASH == CRASH_S2) || (ps_CRASH == CRASH_S3);

    // Crash FSM Next State Logic
    always_comb begin
        case (ps_CRASH)
            READY_CRASH: begin
                if (collision_Imminent)
                    ns_CRASH = CRASH_S1;     // Start crash sequence
                else
                    ns_CRASH = READY_CRASH;  // Remain in ready state
            end
            CRASH_S1:
                ns_CRASH = CRASH_S2;         // Transition to next step in crash
            CRASH_S2:
                ns_CRASH = CRASH_S3;         // Transition to next step in crash
            CRASH_S3:
                ns_CRASH = READY_CRASH;      // Reset crash FSM
        endcase
    end

endmodule


module collision_Intersect_tb();

	logic traffic_clk;               // Traffic system clock
   logic reset;                     // System reset signal
   logic collision_Cases;           // Indicates whether a collision case is detected
   logic turning_Car_Incoming;      // Indicates whether a turning car is incoming

   logic show_Pass;                // Signal to show a car can safely pass
   logic [3:0] collision_Counter;  // 4-bit counter for collision occurrences
   logic show_Crash;               // Signal to indicate a crash is in progress

	collision_Intersect dut (traffic_clk, reset, collision_Cases, turning_Car_Incoming, show_Pass, collision_Counter, show_Crash);

// Clock period for simulation
	parameter CLOCK_PERIOD = 100;
	
	// Generate a clock signal for testing
	initial begin
		traffic_clk <= 0;
		forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;
	end

	// Testbench logic to apply signals and observe behavior
	initial begin
		reset <= 1; collision_Cases <= 0; turning_Car_Incoming <= 0; repeat(4) @(posedge traffic_clk);
		
		reset <= 0; collision_Cases <= 0; turning_Car_Incoming <= 1;           @(posedge traffic_clk);
		reset <= 0; collision_Cases <= 0; turning_Car_Incoming <= 0; repeat(6) @(posedge traffic_clk);
		
		reset <= 0; collision_Cases <= 1; turning_Car_Incoming <= 1;           @(posedge traffic_clk);
		reset <= 0; collision_Cases <= 0; turning_Car_Incoming <= 0; repeat(6) @(posedge traffic_clk);
		
		reset <= 0; collision_Cases <= 1; turning_Car_Incoming <= 1;           @(posedge traffic_clk);
		reset <= 0; collision_Cases <= 0; turning_Car_Incoming <= 0; repeat(6) @(posedge traffic_clk);

      reset <= 0; collision_Cases <= 1; turning_Car_Incoming <= 1;           @(posedge traffic_clk);
		reset <= 0; collision_Cases <= 0; turning_Car_Incoming <= 0; repeat(6) @(posedge traffic_clk);
	
		$stop; // Stop the simulation
	end

endmodule



 