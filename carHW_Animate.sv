
// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Module to animate the movement of cars across a highway using a shift register mechanism
module carHW_Animate (traffic_clk, reset, add_car_rand, car_move_array);

    // Input Signals
    input logic traffic_clk;           // Traffic clock signal (drives animation updates)
    input logic reset;                 // Reset signal for initializing the system
    input logic add_car_rand;          // Signal indicating when to add a new car

    // Output Signals
    output logic [13:0] [1:0] car_move_array; // 14-bit array representing the car movement (2 bits per car)

    // Internal Signals
    logic add_car;                    // Temporary signal to hold car addition state
    logic initalize, add_car_stage1, add_car_stage2, space, shift_all;  // State and movement control signals
    
    // State machine enumeration for controlling car addition and movement
    enum {INITALIZE, READY, ADD_CAR_S1, ADD_CAR_S2, SPACE} ps, ns;

    // Combinational logic to determine the next state based on the current state
    always_comb begin
        case(ps)
            INITALIZE: begin 
                ns = READY; // Initial state: Move to READY after initialization
            end
            
            READY: begin
                if (add_car_rand) begin
                    ns = ADD_CAR_S1; // If add_car_rand is high, start adding a car
                end
                else begin
                    ns = READY; // Otherwise, stay in READY state
                end
            end
            
            ADD_CAR_S1: begin
                ns = ADD_CAR_S2; // Move to stage 2 after stage 1 (car addition process)
            end
            
            ADD_CAR_S2: begin
                ns = SPACE; // After adding the car, move to the SPACE state
            end
            
            SPACE: begin
                ns = READY; // After space, go back to READY to wait for the next car addition
            end
        endcase
    end

    // Assign flags for each stage based on the current state
    assign initalize = (ps == INITALIZE); // Check if in initialization state
    assign add_car_stage1 = (ps == ADD_CAR_S1); // Check if in stage 1 (adding car)
    assign add_car_stage2 = (ps == ADD_CAR_S2); // Check if in stage 2 (car added)
    assign space = (ps == SPACE); // Check if in space (resetting car position)
    assign shift_all = (ps != INITALIZE); // Shift cars when not in initialization state
    
    // Flip-flop logic to update the current state on each clock cycle
    always_ff @(posedge traffic_clk) begin
        if (reset) begin
            ps <= INITALIZE; // On reset, initialize the state machine
        end
        else begin
            ps <= ns; // Update to the next state
        end
    end

    // Flip-flop logic to manage car movement across the highway (shift register mechanism)
    always_ff @(posedge traffic_clk) begin
        if (initalize) begin
            car_move_array <= 14'b0; // Initialize all cars to no movement (0) at the start
        end
        else if (add_car_stage1) begin
            car_move_array[00] <= 2'b11; // Add a car at the first position (stage 1)
        end
        else if (add_car_stage2) begin
            car_move_array[00] <= 2'b11; // Confirm the car is added in stage 2
        end
        else if (space) begin
            car_move_array[00] <= 2'b00; // Move the car off the array (empty space)
        end

        // Shift all cars in the array one position to the right on each clock cycle
        if (shift_all) begin
            car_move_array[01] <= car_move_array[00]; // Shift car positions
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
            car_move_array[13] <= car_move_array[12]; // Shift the last car out of the array
        end
    end

endmodule


// Testbench for carHW_Animate module
module carHW_Animate_tb();

    // Declare testbench signals
    logic traffic_clk, reset, add_car_rand;
    logic [13:0] [1:0] car_move_array;
    
    // Instantiate the device under test (DUT)
    carHW_Animate dut (traffic_clk, reset, add_car_rand, car_move_array);

    // Parameter for clock period (in simulation time units)
    parameter CLOCK_PERIOD = 100;
    
    // Clock generation: toggle traffic_clk every half clock period
    initial begin
        traffic_clk <= 0;
        forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;  // Periodic clock signal
    end

    // Test stimulus generation
    initial begin
        // Initialize signals and apply reset
        reset <= 1; add_car_rand <= 0; repeat(4)  @(posedge traffic_clk); // Wait for 4 clock cycles
        reset <= 0; add_car_rand <= 0; repeat(4)  @(posedge traffic_clk); // Wait for 4 more cycles without adding car
        reset <= 0; add_car_rand <= 1;            @(posedge traffic_clk); // Add a car
        reset <= 0; add_car_rand <= 0; repeat(20) @(posedge traffic_clk); // Wait for 20 cycles after car addition
        reset <= 0; add_car_rand <= 1; repeat(40) @(posedge traffic_clk); // Add another car after 40 cycles
    
        // Stop the simulation after all tests are done
        $stop;
    end

endmodule


