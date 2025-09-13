

// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Module to add a car based on a random number generator and traffic level switches
module add_Car_RandHW #(parameter INITALIZE_RAND = 0) (traffic_clk, reset, traffic_Level_SWs, highWay_Green, add_Car);

    // Input Signals
    input logic traffic_clk;             // Traffic clock signal
    input logic reset;                   // System reset signal
    input logic highWay_Green;           // Indicates whether the highway light is green
    input logic [4:0] traffic_Level_SWs; // 5-bit input representing traffic level switches (0-31)

    // Output Signal
    output logic add_Car;                // Signal to indicate when to add a car
    
    // Internal Random Number Logic
    logic [4:0] LFRS_Rand_Num;           // 5-bit Linear Feedback Shift Register (LFSR) random number generator

    // Logic to determine if a car should be added:
    // If the traffic level is greater than the random number and the highway light is green, add a car.
    assign add_Car = (traffic_Level_SWs > LFRS_Rand_Num) && highWay_Green;

    // Random number generator (LFSR) logic
    always_ff @ (posedge traffic_clk) begin
        if (reset) begin 
            LFRS_Rand_Num <= INITALIZE_RAND;  // On reset, initialize the random number with a given value (INITALIZE_RAND)
        end else begin
            // Shift the random number to the right
            LFRS_Rand_Num <= LFRS_Rand_Num >> 1;
            // XOR the 3rd and 1st bits to create a new bit for the leftmost position (LFSR feedback)
            LFRS_Rand_Num[4] <= ~(LFRS_Rand_Num[2] ^ LFRS_Rand_Num[0]);
        end
    end

endmodule

// Testbench for add_Car_RandHW module
module add_Car_RandHW_tb();

    // Declare testbench signals
    logic traffic_clk, reset, highWay_Green;
    logic [4:0] traffic_Level_SWs;
    logic add_Car;
    
    // Instantiate the device under test (DUT)
    add_Car_RandHW #(0) dut (traffic_clk, reset, traffic_Level_SWs, highWay_Green, add_Car);
    
    // Parameter for clock period (in simulation time units)
    parameter CLOCK_PERIOD = 100;

    // Clock generation: toggle traffic_clk every half clock period
    initial begin
        traffic_clk <= 0;
        forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;  // Periodic clock signal
    end
    
    // Test stimulus generation
    integer i;
    initial begin
        // Initialize signals and apply reset
        reset <= 1; highWay_Green <= 0; traffic_Level_SWs <= 5'b00000; repeat(4) @(posedge traffic_clk);  // Wait 4 clock cycles
        
        // Test case: Vary traffic_Level_SWs and check add_Car behavior
        for (i = 0; i < 32; i++) begin
            reset <= 0;                  // Release reset
            highWay_Green <= 1;          // Set highway light to green
            traffic_Level_SWs <= i;      // Set the traffic level switch value
            repeat(4) @(posedge traffic_clk);  // Wait for 4 clock cycles to observe the output
        end
        
        // Stop the simulation after all tests are done
        $stop;
    end

endmodule




