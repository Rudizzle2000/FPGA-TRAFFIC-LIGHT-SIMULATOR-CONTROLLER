
// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Module to manage car queue operations (adding and decrementing cars in the queue)
module add_Car_To_Queue (traffic_clk, reset, add_car_to_queue, dec_car_in_queue, car_in_queue, car_queue_counter);

    // Input Signals
    input logic traffic_clk;           // Traffic clock signal (drives updates)
    input logic reset;                 // Reset signal to initialize the queue
    input logic add_car_to_queue;      // Signal to add a car to the queue
    input logic dec_car_in_queue;      // Signal to decrement the car count in the queue

    // Output Signals
    output logic car_in_queue;         // Indicates whether there are cars in the queue (car_queue_counter > 0)
    output logic [3:0] car_queue_counter; // 4-bit counter to track the number of cars in the queue

    // Assign car_in_queue based on the car_queue_counter value (if > 0, car_in_queue is true)
    assign car_in_queue = (car_queue_counter > 0);

    // Always block to update the car queue based on the input signals
    always_ff @(posedge traffic_clk) begin
        if (reset) begin
            // On reset, initialize the car_queue_counter to 0 (no cars in the queue)
            car_queue_counter <= 0;
        end
        else if (add_car_to_queue && (car_queue_counter < 15)) begin
            // If add_car_to_queue is true and the counter is less than the max (15), increment the counter
            car_queue_counter <= car_queue_counter + 4'b0001;
        end
        else if (dec_car_in_queue && car_in_queue) begin
            // If dec_car_in_queue is true and there are cars in the queue, decrement the counter
            car_queue_counter <= car_queue_counter - 4'b0001;
        end
    end

endmodule


// Testbench for add_Car_To_Queue module
module add_Car_To_Queue_tb();

    // Declare testbench signals
    logic traffic_clk, reset, add_car_to_queue, dec_car_in_queue;
    logic car_in_queue;

    // Instantiate the device under test (DUT)
    add_Car_To_Queue dut (traffic_clk, reset, add_car_to_queue, dec_car_in_queue, car_in_queue);

    // Parameter for clock period (in simulation time units)
    parameter CLOCK_PERIOD = 100;
    
    // Clock generation: toggle traffic_clk every half of the clock period
    initial begin
        traffic_clk <= 0;
        forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;  // Periodic clock signal
    end

    // Test stimulus generation
    initial begin
        // Apply reset and initialize signals
        reset <= 1; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        
        // Test adding cars to the queue
        reset <= 0; add_car_to_queue <= 1; dec_car_in_queue <= 0; repeat(40) @(posedge traffic_clk);
        
        // Test decrementing cars in the queue
        reset <= 0; add_car_to_queue <= 0; dec_car_in_queue <= 1; repeat(40) @(posedge traffic_clk);
        
        // Stop the simulation after all tests are done
        $stop;
    end

endmodule


