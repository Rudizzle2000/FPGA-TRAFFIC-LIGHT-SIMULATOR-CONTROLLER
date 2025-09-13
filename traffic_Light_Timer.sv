

// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// traffic_Light_Timer
// DESCRIPTION: This module implements a timer for traffic light control, 
//              which counts clock cycles to measure the duration of green or yellow lights.
// PARAMETERS: 
//   - LIGHT_TIMER_SET: Configurable parameter defining the number of cycles for the timer.

module traffic_Light_Timer #(parameter LIGHT_TIMER_SET = 5) (
    input logic clk,             // System clock
    input logic reset,           // Reset signal, active high
    input logic timerStart,      // Signal to start the timer
    output logic timerDone       // Signal indicating the timer has completed
);

    logic [14:0] counter;        // Counter to track elapsed cycles
    logic timerEnable;           // Enable signal for the counter

    // State enumeration for the FSM
    // setTimer: Timer is inactive, waiting for the start signal
    // enableTimer: Timer is active and counting
    enum {setTimer, enableTimer} ps, ns;

    // Timer completion condition
    // timerDone is asserted when the counter reaches the configured LIGHT_TIMER_SET value
    assign timerDone = (counter == LIGHT_TIMER_SET);

    // Timer enable logic
    // Timer is enabled in the enableTimer state
    assign timerEnable = (ps == enableTimer);

    // Counter logic
    // Increment the counter when timerEnable is asserted; otherwise, reset it to 0
    always_ff @(posedge clk) begin
        if (timerEnable) begin
            counter <= counter + 14'b00000000000001; // Increment counter
        end else begin
            counter <= 14'b00000000000000;          // Reset counter
        end
    end

    // Next-state logic for the FSM
    // Defines state transitions based on inputs and current state
    always_comb begin
        case (ps)
            setTimer: begin
                if (timerStart) begin
                    ns = enableTimer; // Start the timer
                end else begin
                    ns = setTimer;    // Remain in setTimer state
                end
            end

            enableTimer: begin
                if (timerDone) begin
                    ns = setTimer;    // Timer complete, return to setTimer state
                end else begin
                    ns = enableTimer; // Continue counting
                end
            end
        endcase
    end

    // State transition logic
    // Updates the present state (ps) on each clock cycle
    always_ff @(posedge clk) begin
        if (reset) begin
            ps <= setTimer; // Reset to the initial state
        end else begin
            ps <= ns;       // Move to the next state
        end
    end

endmodule



// traffic_Light_Timer_tb
// DESCRIPTION: Testbench for the traffic_Light_Timer module. 
//              Verifies the correct behavior of the timer under different scenarios.

module traffic_Light_Timer_tb();

    logic clk, reset, timerStart; // Inputs for the timer module
    logic timerDone;              // Output from the timer module

    // Timer parameters for green and yellow lights
    parameter GREEN_LIGHT_TIMER_SET = 5; 
    parameter YELLOW_LIGHT_TIMER_SET = 3;

    // Instantiate the DUT (Device Under Test) for green and yellow light timers
    traffic_Light_Timer #(GREEN_LIGHT_TIMER_SET) dut_GREEN (
        .clk(clk), .reset(reset), .timerStart(timerStart), .timerDone(timerDone)
    );
    
    traffic_Light_Timer #(YELLOW_LIGHT_TIMER_SET) dut_YELLOW (
        .clk(clk), .reset(reset), .timerStart(timerStart), .timerDone(timerDone)
    );

    // Clock period definition for simulation
    parameter CLOCK_PERIOD = 100;

    // Clock generation process
    initial begin
        clk <= 0;                         // Initialize clock
        forever #(CLOCK_PERIOD / 2) clk <= ~clk; // Toggle clock
    end

    // Test sequence
    initial begin
        /* ============================= SYSTEM RESET ============================= */
        reset <= 1; timerStart <= 0;      // Assert reset and ensure timer is off
        repeat(4) @(posedge clk);         // Wait for a few clock cycles
        
        /* ============================= GREEN LIGHT TIMER ============================= */
        reset <= 0; timerStart <= 1;      // Start the green light timer
        @(posedge clk);                   // Wait for one clock cycle
        reset <= 0; timerStart <= 0;      // Stop the timer
        repeat(5) @(posedge clk);         // Let the timer run for a few cycles
        
        /* ============================= SYSTEM RESET ============================= */
        reset <= 1; timerStart <= 0;      // Reassert reset
        repeat(4) @(posedge clk);         // Wait for a few clock cycles
        
        /* ============================= YELLOW LIGHT TIMER ============================= */
        reset <= 0; timerStart <= 1;      // Start the yellow light timer
        @(posedge clk);                   // Wait for one clock cycle
        reset <= 0; timerStart <= 0;      // Stop the timer
        repeat(10) @(posedge clk);        // Allow timer to run longer than necessary
        
        $stop;                            // End simulation
    end

endmodule

