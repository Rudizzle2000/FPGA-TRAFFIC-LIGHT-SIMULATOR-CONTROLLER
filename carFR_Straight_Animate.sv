
// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Module to animate car movement across a straight path using a shift register mechanism
module carFR_Straight_Animate(traffic_clk, reset, add_car, car_move_array, decrement_car);

    // Input Signals
    input logic traffic_clk;           // Traffic clock signal (drives animation updates)
    input logic reset;                 // Reset signal to initialize the system
    input logic add_car;               // Signal indicating when to add a new car

    // Output Signals
    output logic [1:0] [13:0] car_move_array; // 14-bit array representing car movement (2 bits per car)
    output logic decrement_car;        // Signal to indicate when to decrement (move out) the car

    // Internal Signals
    logic initalize, add_car_state, space, shift_all;

    // State machine enumeration for controlling car addition and movement
    enum {INITALIZE, READY, ADD_CAR_S1, ADD_CAR_S2, SPACE} ps, ns;

    // Combinational logic to determine the next state based on the current state
    always_comb begin
        case(ps)
            INITALIZE: begin 
                ns = READY; // Initial state: Move to READY after initialization
            end
            
            READY: begin
                if (add_car) begin
                    ns = ADD_CAR_S1; // If add_car is high, start adding a car
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
    assign add_car_state = (ps == ADD_CAR_S2) || (ps == ADD_CAR_S1); // Check if in car addition state
    assign space = (ps == SPACE); // Check if in space state (resetting car position)
    assign shift_all = (ps != INITALIZE); // Shift cars when not in initialization state
    assign decrement_car = (ps == ADD_CAR_S1); // Signal to decrement car when in ADD_CAR_S1 state

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
            // Initialize the car array to zero (no cars present)
            car_move_array[0] <= 14'b0;
            car_move_array[1] <= 14'b0;
        end
        else if (add_car_state) begin
            // Add a car at the first position (both rows)
            car_move_array[0][0] <= 1'b1;
            car_move_array[1][0] <= 1'b1;
        end
        else if (space) begin
            // Empty the car at the first position (both rows)
            car_move_array[0][0] <= 1'b0;
            car_move_array[1][0] <= 1'b0;
        end

        // Shift all cars to the right on each clock cycle
        if (shift_all) begin
            car_move_array[0][1] <= car_move_array[0][0]; // Shift car positions (row 0)
            car_move_array[1][1] <= car_move_array[1][0]; // Shift car positions (row 1)

            car_move_array[0][2] <= car_move_array[0][1];
            car_move_array[1][2] <= car_move_array[1][1];

            car_move_array[0][3] <= car_move_array[0][2];
            car_move_array[1][3] <= car_move_array[1][2];

            car_move_array[0][4] <= car_move_array[0][3];
            car_move_array[1][4] <= car_move_array[1][3];

            car_move_array[0][5] <= car_move_array[0][4];
            car_move_array[1][5] <= car_move_array[1][4];

            car_move_array[0][6] <= car_move_array[0][5];
            car_move_array[1][6] <= car_move_array[1][5];

            car_move_array[0][7] <= car_move_array[0][6];
            car_move_array[1][7] <= car_move_array[1][6];

            car_move_array[0][8] <= car_move_array[0][7];
            car_move_array[1][8] <= car_move_array[1][7];

            car_move_array[0][9] <= car_move_array[0][8];
            car_move_array[1][9] <= car_move_array[1][8];

            car_move_array[0][10] <= car_move_array[0][9];
            car_move_array[1][10] <= car_move_array[1][9];

            car_move_array[0][11] <= car_move_array[0][10];
            car_move_array[1][11] <= car_move_array[1][10];

            car_move_array[0][12] <= car_move_array[0][11];
            car_move_array[1][12] <= car_move_array[1][11];

            car_move_array[0][13] <= car_move_array[0][12];
            car_move_array[1][13] <= car_move_array[1][12]; // Final position (shifted out of the array)
        end
    end

endmodule


// Testbench for carFR_Straight_Animate module
module carFR_Straight_Animate_tb();

    // Declare testbench signals
    logic traffic_clk, reset, add_car;
    logic [1:0] [13:0] car_move_array;
    logic decrement_car;
    
    // Instantiate the device under test (DUT)
    carFR_Straight_Animate dut (traffic_clk, reset, add_car, car_move_array, decrement_car);

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
        reset <= 1; add_car <= 0; repeat(4)  @(posedge traffic_clk); // Wait for 4 clock cycles
        reset <= 0; add_car <= 0; repeat(4)  @(posedge traffic_clk); // Wait for 4 more cycles without adding car
        reset <= 0; add_car <= 1;            @(posedge traffic_clk); // Add a car
        reset <= 0; add_car <= 0; repeat(20) @(posedge traffic_clk); // Wait for 20 cycles after car addition
        reset <= 0; add_car <= 1; repeat(40) @(posedge traffic_clk); // Add another car after 40 cycles
        reset <= 0; add_car <= 0; repeat(10) @(posedge traffic_clk); // Stop adding cars for 10 cycles
    
        // Stop the simulation after all tests are done
        $stop;
    end

endmodule




