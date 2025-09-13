




// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// This module ensure that one logic high on the input in is read by the system as 
// one keypress rather than multiple keypresses. The keypress module takes a 1-bit input logic signal, and 
// outputs a signal that is properly read for every individual keypress given.
// One keypress module:
// Inputs: clock, 1-bit reset, 1-bit logic signal.
// Outputs: 1-bit logic signal.
module keypress (clk, reset, in, out);

	input logic clk, reset, in; 
	output logic out;
	
	enum {S0, S1} ps, ns;
	
	// Combinational logic that determines what state the keypress module should be in.
	always_comb begin
		case (ps)
		
			S0: if (in) ns = S1;
					else ns = S0;
					
			S1: if (in) ns = S1;
					else ns = S0;
					
		endcase
	end
			
	assign out = (ps == S1) & ~in; 

		// sequential logic that determines what should happen if reset is set hight or low.
		always_ff @(posedge clk) begin
			if (reset)
				ps <= S0;
			else
				ps <= ns;
		end
endmodule

// Testbench for the keypress module. Tests whether the module can account for both
// one long and short keypress as one individual logic high input w/ and w/out being reset.
// Allows one to check that the correct output is being given.
module keypress_testbench();

		logic clk, reset, in, out;
		
		keypress dut (.clk, .reset, .in, .out);
		
		parameter clock_period = 100;
		
		initial begin
			clk <= 0;
			forever #(clock_period /2) clk <= ~clk;
					
		end 
		
		initial begin
		
			reset <= 1;         @(posedge clk); 
			reset <= 0; in<=0;  @(posedge clk); 
			                    @(posedge clk); 
			            in<=1;  @(posedge clk);	
									  @(posedge clk); 
			                    @(posedge clk); 
							in<=0;  @(posedge clk); 	
			            in<=1;  @(posedge clk);	
							in<=0;  @(posedge clk); 	
			                    @(posedge clk); 
									  
			reset <= 1; in<=0;  @(posedge clk); 
									  @(posedge clk); 
			                    @(posedge clk); 
			            in<=1;  @(posedge clk);
									  @(posedge clk); 
			                    @(posedge clk); 
							in<=0;  @(posedge clk); 	
			            in<=1;  @(posedge clk);		
							in<=0;  @(posedge clk); 	
			                    @(posedge clk); 							
									  							  									  
			$stop;										
		end		
endmodule		
