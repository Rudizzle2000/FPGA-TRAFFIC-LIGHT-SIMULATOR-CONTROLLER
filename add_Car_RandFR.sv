
// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Module to add a car randomly based on the farm road traffic light and traffic level
module add_Car_RandFR #(parameter INITALIZE_RAND = 0) (traffic_clk, reset, FarmRoad_Green, car_in_queue, traffic_Level_SWs, add_Car);

    // Input Signals
    input logic traffic_clk;          // Traffic clock signal (drives updates)
    input logic reset;                // Reset signal to initialize the module
    input logic FarmRoad_Green;       // Green light signal for the farm road (when true, cars can be added)
    input logic car_in_queue;         // Signal indicating that there are cars in the queue to add
    input logic [4:0] traffic_Level_SWs; // 5-bit input representing traffic level from a switch (controls car addition probability)

    // Output Signal
    output logic add_Car;             // Signal to indicate whether a car should be added to the queue

    // Internal Signals
    logic [4:0] LFRS_Rand_Num;        // 5-bit random number generator for probabilistic car addition

    // Assign add_Car signal based on traffic level, green light, and car availability
    // If traffic level is greater than the random number, and farm road light is green, and car is in queue
    assign add_Car = (traffic_Level_SWs > LFRS_Rand_Num) && FarmRoad_Green && car_in_queue;

    // Random number generator (Linear Feedback Shift Register - LFSR)
    always_ff @(posedge traffic_clk) begin
        if (reset) begin
            // On reset, initialize the random number generator with the parameter value
            LFRS_Rand_Num <= INITALIZE_RAND;
        end
        else begin
            // Shift the random number right by 1 bit and update the most significant bit (bit 4)
            // The new bit is generated based on an XOR of bit 2 and bit 0
            LFRS_Rand_Num <= LFRS_Rand_Num >> 1;
            LFRS_Rand_Num[4] <= ~(LFRS_Rand_Num[2] ^ LFRS_Rand_Num[0]);
        end
    end

endmodule


// Testbench for add_Car_RandFR module
module add_Car_RandFR_tb();

    // Declare testbench signals
    logic traffic_clk, reset, FarmRoad_Green, car_in_queue;
    logic [4:0] traffic_Level_SWs;
    logic add_Car;

    // Instantiate the device under test (DUT)
    add_Car_RandFR #(16) dut (traffic_clk, reset, FarmRoad_Green, car_in_queue, traffic_Level_SWs, add_Car);

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
        reset <= 1; FarmRoad_Green <= 0; car_in_queue <= 0; traffic_Level_SWs <= 5'b00000; repeat(4) @(posedge traffic_clk);
        
        // Apply different traffic levels and test car addition
        for (i = 0; i < 32; i++) begin
            reset <= 0; FarmRoad_Green <= 1; car_in_queue <= 1; traffic_Level_SWs <= i; repeat(4) @(posedge traffic_clk);
        end
    
        // Stop the simulation after all tests are done
        $stop;
    end

endmodule



