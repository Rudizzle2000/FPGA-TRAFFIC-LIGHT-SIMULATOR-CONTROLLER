
// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller


// trafficL_ctrl_timer_wrapper module
// DESCRIPTION: This module coordinates the control logic for traffic lights at an intersection 
//              by integrating traffic light control signals with associated timers. The timers
//              govern the duration of green and yellow lights based on parameterized values. 
//              The wrapper interfaces with a traffic light control module and two timer modules 
//              (one for green and one for yellow lights).

module trafficL_ctrl_timer_wrapper 
    #(parameter GREEN_LIGHT_TIMER_SET = 5, // Number of clock cycles for the green light duration
                YELLOW_LIGHT_TIMER_SET = 3) // Number of clock cycles for the yellow light duration
    (
        input logic clk,            // System clock
        input logic reset,          // Reset signal, active high
        input logic sensor_i,       // Sensor input indicating traffic presence
        output logic highW_G_farm_R_o, // Output to signal highway green, farm road red
        output logic highW_Y_farm_R_o, // Output to signal highway yellow, farm road red
        output logic highW_R_farm_G_o, // Output to signal highway red, farm road green
        output logic highW_R_farm_Y_o  // Output to signal highway red, farm road yellow
    );

    // Internal signals
    logic timerG_Done;             // Indicates completion of the green light timer
    logic timerY_Done;             // Indicates completion of the yellow light timer
    logic startTimer_G;            // Signal to start the green light timer
    logic startTimer_Y;            // Signal to start the yellow light timer

    // Traffic Light Control Module
    // INPUTS:
    //    - clk: Clock signal
    //    - reset: Reset signal
    //    - sensor_i: Sensor input for traffic detection
    //    - timerG_Done_i: Indicates green light timer is complete
    //    - timerY_Done_i: Indicates yellow light timer is complete
    // OUTPUTS:
    //    - startTimer_G_o: Signal to initiate the green light timer
    //    - startTimer_Y_o: Signal to initiate the yellow light timer
    //    - highW_G_farm_R_o: Controls highway green, farm road red lights
    //    - highW_Y_farm_R_o: Controls highway yellow, farm road red lights
    //    - highW_R_farm_G_o: Controls highway red, farm road green lights
    //    - highW_R_farm_Y_o: Controls highway red, farm road yellow lights
    trafficLight_ctrl TL_Ctrl (
        .clk(clk), 
        .reset(reset), 
        .sensor_i(sensor_i), 
        .timerG_Done_i(timerG_Done), 
        .timerY_Done_i(timerY_Done), 
        .startTimer_G_o(startTimer_G), 
        .startTimer_Y_o(startTimer_Y), 
        .highW_G_farm_R_o(highW_G_farm_R_o), 
        .highW_Y_farm_R_o(highW_Y_farm_R_o), 
        .highW_R_farm_G_o(highW_R_farm_G_o), 
        .highW_R_farm_Y_o(highW_R_farm_Y_o)
    );

    // Green Light Timer Module
    // INPUTS:
    //    - clk: Clock signal
    //    - reset: Reset signal
    //    - timerStart: Signal to initiate the green light timer
    // OUTPUTS:
    //    - timerDone: Indicates green light timer completion
    traffic_Light_Timer #(GREEN_LIGHT_TIMER_SET) TimerG (
        .clk(clk), 
        .reset(reset), 
        .timerStart(startTimer_G), 
        .timerDone(timerG_Done)
    );
     
    // Yellow Light Timer Module
    // INPUTS:
    //    - clk: Clock signal
    //    - reset: Reset signal
    //    - timerStart: Signal to initiate the yellow light timer
    // OUTPUTS:
    //    - timerDone: Indicates yellow light timer completion
    traffic_Light_Timer #(YELLOW_LIGHT_TIMER_SET) TimerY (
        .clk(clk), 
        .reset(reset), 
        .timerStart(startTimer_Y), 
        .timerDone(timerY_Done)
    );

endmodule



module trafficL_ctrl_timer_wrapper_tb();

	logic clk, reset, sensor_i;
	logic highW_G_farm_R_o, highW_Y_farm_R_o, highW_R_farm_G_o, highW_R_farm_Y_o;

	parameter GREEN_LIGHT_TIMER_SET = 5;
	parameter YELLOW_LIGHT_TIMER_SET = 3;
	parameter CLOCK_PERIOD = 100;

	trafficL_ctrl_timer_wrapper #(GREEN_LIGHT_TIMER_SET, YELLOW_LIGHT_TIMER_SET) dut (clk, reset, sensor_i, highW_G_farm_R_o, highW_Y_farm_R_o, highW_R_farm_G_o, highW_R_farm_Y_o);
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		
		reset <= 1; sensor_i <= 0; repeat(8) @(posedge clk);
		reset <= 0; sensor_i <= 1; repeat(30) @(posedge clk);
		
		$stop;
	end

endmodule



