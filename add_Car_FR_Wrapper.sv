

// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Wrapper module that integrates car queue management and random car addition logic for a farm road scenario
module add_Car_FR_Wrapper #(parameter INITALIZE_RAND = 0) (traffic_clk, reset, FarmRoad_Green, add_car_to_queue, dec_car_in_queue, 
                                                           traffic_Level_SWs, add_Car, car_queue_counter);

    // Input Signals
    input logic traffic_clk;           // Traffic clock signal (drives updates)
    input logic reset;                 // Reset signal to initialize the system
    input logic FarmRoad_Green;        // Indicates if the farm road's traffic light is green (green allows car addition)
    input logic add_car_to_queue;      // Signal to attempt adding a car to the queue
    input logic dec_car_in_queue;      // Signal to attempt removing a car from the queue
    input logic [4:0] traffic_Level_SWs; // A switch to set traffic level (used for random car addition decision)

    // Output Signals
    output logic add_Car;              // Signal indicating if a car should be added
    output logic [3:0] car_queue_counter; // 4-bit counter to track the number of cars in the queue

    // Internal Signals
    logic button_press, car_in_queue;

    // Instantiating the keypress module to detect a button press (controlled by add_car_to_queue signal)
    keypress KP (.clk(traffic_clk), .reset(reset), .in(add_car_to_queue), .out(button_press));

    // Instantiate the queue management module, which handles adding/removing cars from the queue
    add_Car_To_Queue QUEUE(
        .traffic_clk(traffic_clk), 
        .reset(reset), 
        .add_car_to_queue(button_press), // Pass the processed button press signal to add car
        .dec_car_in_queue(dec_car_in_queue), 
        .car_in_queue(car_in_queue), 
        .car_queue_counter(car_queue_counter)
    );

    // Instantiate the random car addition logic, which decides when to add a car based on the traffic level
    add_Car_RandFR #(INITALIZE_RAND) RAND (
        .traffic_clk(traffic_clk), 
        .reset(reset), 
        .FarmRoad_Green(FarmRoad_Green), 
        .car_in_queue(car_in_queue), 
        .traffic_Level_SWs(traffic_Level_SWs), 
        .add_Car(add_Car)
    );

endmodule


// Testbench for add_Car_FR_Wrapper module
module add_Car_FR_Wrapper_tb();

    // Declare testbench signals
    logic traffic_clk, reset, FarmRoad_Green, add_car_to_queue, dec_car_in_queue;
    logic [4:0] traffic_Level_SWs;
    logic add_Car;

    // Instantiate the device under test (DUT)
    add_Car_FR_Wrapper #(12) dut(traffic_clk, reset, FarmRoad_Green, add_car_to_queue, dec_car_in_queue, traffic_Level_SWs, add_Car);

    // Parameter for clock period (in simulation time units)
    parameter CLOCK_PERIOD = 100;
    
    // Clock generation: toggle traffic_clk every half of the clock period
    initial begin
        traffic_clk <= 0;
        forever #(CLOCK_PERIOD / 2) traffic_clk <= ~traffic_clk;  // Periodic clock signal
    end
    
    // Test stimulus generation
	 integer i;
    initial begin

        /* ======================================== LEVEL 4 ADD/REMOVE CARS ======================================== */
        // Test with traffic level 4: add and remove cars to/from the queue
        reset <= 1; traffic_Level_SWs <= 4; FarmRoad_Green <= 0; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        
        // Add cars to the queue while the traffic light is green and traffic level is 4
        for (i = 0; i < 35; i++) begin
            reset <= 0; traffic_Level_SWs <= 4; FarmRoad_Green <= 1; add_car_to_queue <= 1; dec_car_in_queue <= 0; @(posedge traffic_clk);
            reset <= 0; traffic_Level_SWs <= 4; FarmRoad_Green <= 1; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        end
        
        // Remove cars from the queue while the traffic light is green and traffic level is 4
        for (i = 0; i < 35; i++) begin
            reset <= 0; traffic_Level_SWs <= 4; FarmRoad_Green <= 1; add_car_to_queue <= 0; dec_car_in_queue <= 1; @(posedge traffic_clk);
            reset <= 0; traffic_Level_SWs <= 4; FarmRoad_Green <= 1; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        end
        
        /* ======================================== LEVEL 16 ADD/REMOVE CARS ======================================== */
        // Test with traffic level 16: add and remove cars to/from the queue
        reset <= 1; traffic_Level_SWs <= 16; FarmRoad_Green <= 0; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        
        // Add cars to the queue while the traffic light is green and traffic level is 16
        for (i = 0; i < 35; i++) begin
            reset <= 0; traffic_Level_SWs <= 16; FarmRoad_Green <= 1; add_car_to_queue <= 1; dec_car_in_queue <= 0; @(posedge traffic_clk);
            reset <= 0; traffic_Level_SWs <= 16; FarmRoad_Green <= 1; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        end
        
        // Remove cars from the queue while the traffic light is green and traffic level is 16
        for (i = 0; i < 35; i++) begin
            reset <= 0; traffic_Level_SWs <= 16; FarmRoad_Green <= 1; add_car_to_queue <= 0; dec_car_in_queue <= 1; @(posedge traffic_clk);
            reset <= 0; traffic_Level_SWs <= 16; FarmRoad_Green <= 1; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        end
        
        /* ======================================== TEST FARM ROAD GREEN LIGHT LOGIC ======================================== */
        // Test with FarmRoad Green light OFF
        reset <= 1; traffic_Level_SWs <= 16; FarmRoad_Green <= 0; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        
        // Try to add cars to the queue while the traffic light is red
        for (i = 0; i < 35; i++) begin
            reset <= 0; traffic_Level_SWs <= 16; FarmRoad_Green <= 0; add_car_to_queue <= 1; dec_car_in_queue <= 0; @(posedge traffic_clk);
            reset <= 0; traffic_Level_SWs <= 16; FarmRoad_Green <= 0; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        end
        
        // Try to remove cars from the queue while the traffic light is red
        for (i = 0; i < 35; i++) begin
            reset <= 0; traffic_Level_SWs <= 16; FarmRoad_Green <= 0; add_car_to_queue <= 0; dec_car_in_queue <= 1; @(posedge traffic_clk);
            reset <= 0; traffic_Level_SWs <= 16; FarmRoad_Green <= 0; add_car_to_queue <= 0; dec_car_in_queue <= 0; @(posedge traffic_clk);
        end

        // Stop the simulation
        $stop;
    end

endmodule



