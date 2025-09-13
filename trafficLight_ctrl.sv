

// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// trafficLight_ctrl
// DESCRIPTION: This module implements the finite state machine (FSM) to control traffic lights at an intersection. 
//              It transitions through states to manage highway and farm road signals based on sensor input 
//              and timer completions. The FSM coordinates which timer to start and outputs control signals 
//              to set the appropriate light state.

module trafficLight_ctrl (
    input logic clk,                  // System clock
    input logic reset,                // Reset signal, active high
    input logic sensor_i,             // Sensor input indicating the presence of vehicles
    input logic timerG_Done_i,        // Signal indicating the green light timer is complete
    input logic timerY_Done_i,        // Signal indicating the yellow light timer is complete
    output logic startTimer_G_o,      // Signal to start the green light timer
    output logic startTimer_Y_o,      // Signal to start the yellow light timer
    output logic highW_G_farm_R_o,    // Output signal: highway green, farm road red
    output logic highW_Y_farm_R_o,    // Output signal: highway yellow, farm road red
    output logic highW_R_farm_G_o,    // Output signal: highway red, farm road green
    output logic highW_R_farm_Y_o     // Output signal: highway red, farm road yellow
);

    // State enumeration for the FSM
    // HG_FR_loop  : Highway green, farm road red - idle state (no sensor input)
    // HG_FR_sense : Highway green, farm road red - active state (sensor detected traffic)
    // HY_FR       : Highway yellow, farm road red
    // HR_FG       : Highway red, farm road green
    // HR_FY       : Highway red, farm road yellow
    enum {HG_FR_loop, HG_FR_sense, HY_FR, HR_FG, HR_FY} ps, ns;

    // Outputs for the current state of traffic lights
    // Assign appropriate light signals based on the present state (ps)
    assign highW_G_farm_R_o = (ps == HG_FR_loop) || (ps == HG_FR_sense);
    assign highW_Y_farm_R_o = (ps == HY_FR);
    assign highW_R_farm_G_o = (ps == HR_FG);
    assign highW_R_farm_Y_o = (ps == HR_FY);

    // State transition logic
    // Updates the present state (ps) on each clock cycle
    always_ff @(posedge clk) begin
        if (reset) begin
            ps <= HG_FR_loop; // Reset to the default idle state
        end else begin
            ps <= ns;         // Move to the next state
        end
    end    

    // Next-state logic and output generation
    // Determines the next state (ns) based on the current state (ps) and inputs
    always_comb begin
        case(ps)
            // Idle state: Highway green, farm road red
            // Transition to active green state if traffic is detected
            HG_FR_loop: begin
                if (sensor_i) begin
                    ns = HG_FR_sense; 
                    startTimer_G_o = 1'b1; // Start green light timer
                    startTimer_Y_o = 1'b0;
                end else begin
                    ns = HG_FR_loop; 
                    startTimer_G_o = 1'b0; 
                    startTimer_Y_o = 1'b0;
                end
            end
            
            // Active green state: Highway green, farm road red
            // Transition to yellow state once the green light timer is complete
            HG_FR_sense: begin
                if (timerG_Done_i) begin
                    ns = HY_FR; 
                    startTimer_G_o = 1'b0; 
                    startTimer_Y_o = 1'b1; // Start yellow light timer
                end else begin
                    ns = HG_FR_sense; 
                    startTimer_G_o = 1'b0; 
                    startTimer_Y_o = 1'b0;
                end
            end
            
            // Yellow state: Highway yellow, farm road red
            // Transition to farm road green state once the yellow light timer is complete
            HY_FR: begin
                if (timerY_Done_i) begin
                    ns = HR_FG; 
                    startTimer_G_o = 1'b1; // Start green light timer
                    startTimer_Y_o = 1'b0;
                end else begin
                    ns = HY_FR; 
                    startTimer_G_o = 1'b0; 
                    startTimer_Y_o = 1'b0;
                end
            end
            
            // Farm road green state: Highway red, farm road green
            // Transition to yellow state once the green light timer is complete
            HR_FG: begin
                if (timerG_Done_i) begin
                    ns = HR_FY; 
                    startTimer_G_o = 1'b0; 
                    startTimer_Y_o = 1'b1; // Start yellow light timer
                end else begin
                    ns = HR_FG; 
                    startTimer_G_o = 1'b0; 
                    startTimer_Y_o = 1'b0;
                end
            end
            
            // Farm road yellow state: Highway red, farm road yellow
            // Transition to highway green idle state once the yellow light timer is complete
            HR_FY: begin
                if (timerY_Done_i) begin
                    ns = HG_FR_loop; 
                    startTimer_G_o = 1'b0; 
                    startTimer_Y_o = 1'b0; // Stop all timers
                end else begin
                    ns = HR_FY; 
                    startTimer_G_o = 1'b0; 
                    startTimer_Y_o = 1'b0;
                end
            end

        endcase
    end

endmodule






module trafficLight_ctrl_tb();

	logic clk, reset, sensor_i, timerG_Done_i, timerY_Done_i;
	logic startTimer_G_o, startTimer_Y_o, highW_G_farm_R_o, highW_Y_farm_R_o, highW_R_farm_G_o, highW_R_farm_Y_o; 

	trafficLight_ctrl dut (clk, reset, sensor_i, timerG_Done_i, timerY_Done_i, startTimer_G_o, startTimer_Y_o, 
								  highW_G_farm_R_o, highW_Y_farm_R_o, highW_R_farm_G_o, highW_R_farm_Y_o);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD) clk <= ~clk;
	end
	
	initial begin
	
		// FOR TESTBENCH:
		// GREEN LIGHT TIMER = 5 CLOCK CYCLES
		// YELLOW LIGHT TIMER = 2 CLOCK CYCLES
	
		/* ============================= SYSTEM RESET ============================= */
		reset <= 1; sensor_i <= 0; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk);
		
		/* ====================================================================================================== */
		/* ************************************** TRAFFIC LIGHT CONTROLLER ************************************** */
		/* ====================================================================================================== */
		
		/* ============================= HIGHWAY LOOP ============================= */
		reset <= 0; sensor_i <= 0; timerG_Done_i <= 0; timerY_Done_i <= 0; repeat(8) @(posedge clk); // ONLY HIGH WAY LIGHT GREEN 

		/* ============================= CAR SENSE ON FARM ROAD ============================= */
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT GREEN, FARM LIGHT RED 
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT GREEN, FARM LIGHT RED 
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT GREEN, FARM LIGHT RED 
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT GREEN, FARM LIGHT RED 
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT GREEN, FARM LIGHT RED 
		
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 1; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT GREEN, FARM LIGHT RED, TIMER FOR GREEN LIGHT DONE 
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGHWAY LIGHT YELLOW, FARM LIGHT RED
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGHWAY LIGHT YELLOW, FARM LIGHT RED
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 1; @(posedge clk); // HIGHWAY LIGHT YELLOW, FARM LIGHT RED, TIMER FOR YELLOW LIGHT DONE,  
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT RED, FARM LIGHT GREEN 
		
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT RED, FARM LIGHT GREEN
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT RED, FARM LIGHT GREEN 
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT RED, FARM LIGHT GREEN 
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT RED, FARM LIGHT GREEN
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT RED, FARM LIGHT GREEM
		
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 1; timerY_Done_i <= 0; @(posedge clk); // HIGH WAY LIGHT RED, FARM LIGHT RED, TIMER FOR GREEN LIGHT DONE 
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGHWAY LIGHT RED, FARM LIGHT YELLOW
		reset <= 0; sensor_i <= 1; timerG_Done_i <= 0; timerY_Done_i <= 0; @(posedge clk); // HIGHWAY LIGHT RED, FARM LIGHT YELLOW
		reset <= 0; sensor_i <= 0; timerG_Done_i <= 0; timerY_Done_i <= 1; @(posedge clk); // HIGHWAY LIGHT RED, FARM LIGHT YELLOW, TIMER FOR YELLOW LIGHT DONE,  
		reset <= 0; sensor_i <= 0; timerG_Done_i <= 0; timerY_Done_i <= 0; repeat(4) @(posedge clk); // HIGH WAY LIGHT RED, FARM LIGHT GREEN 

		$stop;
	end

endmodule 

