
// Rudy Garcia
// 12/05/2024
// EE 598 
// FINAL PROJECT: Traffic Light Simulator/Controller

// Uses the HEX displays to display the car queue counters and the collision counter
module HEX_Display(
    car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_TRoad_LLane, car_queue_counter_FR_BRoad_RLane, car_queue_counter_FR_BRoad_LLane,
    master_Collision_Counter, 
    HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

    // Input signals: 4-bit car queue counters for different lanes and master collision counter
    input logic [3:0] car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_TRoad_LLane, car_queue_counter_FR_BRoad_RLane, car_queue_counter_FR_BRoad_LLane;
    input logic [3:0] master_Collision_Counter;
    
    // Output signals: 7-segment display outputs for each HEX display
    output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    // 7-segment display values for digits 0-9 and letters A-F
    logic [6:0] zero  = 7'b1000000;
    logic [6:0] one   = 7'b1111001;
    logic [6:0] two   = 7'b0100100;
    logic [6:0] three = 7'b0110000;
    logic [6:0] four  = 7'b0011001;
    logic [6:0] five  = 7'b0010010;
    logic [6:0] six   = 7'b0000010;
    logic [6:0] seven = 7'b1111000;
    logic [6:0] eight = 7'b0000000;
    logic [6:0] nine  = 7'b0010000;
    logic [6:0] A_10 =  7'b0001000;  // Representing 'A' for 10
    logic [6:0] B_11 =  7'b0000011;  // Representing 'B' for 11
    logic [6:0] C_12 =  7'b1000110;  // Representing 'C' for 12
    logic [6:0] D_13 =  7'b0100001;  // Representing 'D' for 13
    logic [6:0] E_14 =  7'b0000110;  // Representing 'E' for 14
    logic [6:0] F_15 =  7'b0001110;  // Representing 'F' for 15
    logic [6:0] nothing = 7'b1111111; // Display off or undefined value

    // Hardcoded assignment for HEX3 to display 'C' (12)
    assign HEX3 = C_12;

    always_comb begin
        // Display values for the 'BRoad_LLane' car queue counter on HEX5
        case(car_queue_counter_FR_BRoad_LLane)
            0: HEX5 = zero;
            1: HEX5 = one;
            2: HEX5 = two;
            3: HEX5 = three;
            4: HEX5 = four;
            5: HEX5 = five;
            6: HEX5 = six;
            7: HEX5 = seven;
            8: HEX5 = eight;
            9: HEX5 = nine;
            10: HEX5 = A_10;
            11: HEX5 = B_11;
            12: HEX5 = C_12;
            13: HEX5 = D_13;
            14: HEX5 = E_14;
            15: HEX5 = F_15;
            default: HEX5 = nothing;
        endcase
        
        // Display values for the 'BRoad_RLane' car queue counter on HEX4
        case(car_queue_counter_FR_BRoad_RLane)
            0: HEX4 = zero;
            1: HEX4 = one;
            2: HEX4 = two;
            3: HEX4 = three;
            4: HEX4 = four;
            5: HEX4 = five;
            6: HEX4 = six;
            7: HEX4 = seven;
            8: HEX4 = eight;
            9: HEX4 = nine;
            10: HEX4 = A_10;
            11: HEX4 = B_11;
            12: HEX4 = C_12;
            13: HEX4 = D_13;
            14: HEX4 = E_14;
            15: HEX4 = F_15;
            default: HEX4 = nothing;
        endcase

        // Display values for the master collision counter on HEX2
        case(master_Collision_Counter)
            0: HEX2 = zero;
            1: HEX2 = one;
            2: HEX2 = two;
            3: HEX2 = three;
            4: HEX2 = four;
            5: HEX2 = five;
            6: HEX2 = six;
            7: HEX2 = seven;
            8: HEX2 = eight;
            9: HEX2 = nine;
            10: HEX2 = A_10;
            11: HEX2 = B_11;
            12: HEX2 = C_12;
            13: HEX2 = D_13;
            14: HEX2 = E_14;
            15: HEX2 = F_15;
            default: HEX2 = nothing;
        endcase

        // Display values for the 'TRoad_LLane' car queue counter on HEX1
        case(car_queue_counter_FR_TRoad_LLane)
            0: HEX1 = zero;
            1: HEX1 = one;
            2: HEX1 = two;
            3: HEX1 = three;
            4: HEX1 = four;
            5: HEX1 = five;
            6: HEX1 = six;
            7: HEX1 = seven;
            8: HEX1 = eight;
            9: HEX1 = nine;
            10: HEX1 = A_10;
            11: HEX1 = B_11;
            12: HEX1 = C_12;
            13: HEX1 = D_13;
            14: HEX1 = E_14;
            15: HEX1 = F_15;
            default: HEX1 = nothing;
        endcase

        // Display values for the 'TRoad_RLane' car queue counter on HEX0
        case(car_queue_counter_FR_TRoad_RLane)
            0: HEX0 = zero;
            1: HEX0 = one;
            2: HEX0 = two;
            3: HEX0 = three;
            4: HEX0 = four;
            5: HEX0 = five;
            6: HEX0 = six;
            7: HEX0 = seven;
            8: HEX0 = eight;
            9: HEX0 = nine;
            10: HEX0 = A_10;
            11: HEX0 = B_11;
            12: HEX0 = C_12;
            13: HEX0 = D_13;
            14: HEX0 = E_14;
            15: HEX0 = F_15;
            default: HEX0 = nothing;
        endcase
    end

endmodule


module HEX_Display_tb();

    // Input signals: car queue counters and master collision counter
    logic [3:0] car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_TRoad_LLane;
    logic [3:0] car_queue_counter_FR_BRoad_RLane, car_queue_counter_FR_BRoad_LLane;
    logic [3:0] master_Collision_Counter;

    // Output signals: 7-segment display outputs for each HEX display
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    // Instantiate the DUT (Device Under Test)
    HEX_Display dut (
        .car_queue_counter_FR_TRoad_RLane(car_queue_counter_FR_TRoad_RLane),
        .car_queue_counter_FR_TRoad_LLane(car_queue_counter_FR_TRoad_LLane),
        .car_queue_counter_FR_BRoad_RLane(car_queue_counter_FR_BRoad_RLane),
        .car_queue_counter_FR_BRoad_LLane(car_queue_counter_FR_BRoad_LLane),
        .master_Collision_Counter(master_Collision_Counter),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

    // Testbench logic
    initial begin
        // Display test header
        $display("Starting HEX_Display Testbench...");
        
        // Initialize inputs
        car_queue_counter_FR_TRoad_RLane = 0;
        car_queue_counter_FR_TRoad_LLane = 0;
        car_queue_counter_FR_BRoad_RLane = 0;
        car_queue_counter_FR_BRoad_LLane = 0;
        master_Collision_Counter = 0;

        // Loop through possible values for all counters
        for (int i = 0; i < 16; i++) begin
            car_queue_counter_FR_TRoad_RLane = i;
            car_queue_counter_FR_TRoad_LLane = (15 - i); // Use reverse values for variety
            car_queue_counter_FR_BRoad_RLane = i % 4;    // Cycle through smaller range
            car_queue_counter_FR_BRoad_LLane = (i + 3) % 16;
            master_Collision_Counter = i;

            // Wait for output stabilization
            #10;

            // Print results for verification
            $display("Inputs: TR_RLane=%d, TR_LLane=%d, BR_RLane=%d, BR_LLane=%d, Collision=%d",
                     car_queue_counter_FR_TRoad_RLane, car_queue_counter_FR_TRoad_LLane,
                     car_queue_counter_FR_BRoad_RLane, car_queue_counter_FR_BRoad_LLane,
                     master_Collision_Counter);
            $display("Outputs: HEX5=%b, HEX4=%b, HEX3=%b, HEX2=%b, HEX1=%b, HEX0=%b",
                     HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
        end

        // End simulation
        $display("HEX_Display Testbench Complete.");
        $stop;
    end

endmodule



