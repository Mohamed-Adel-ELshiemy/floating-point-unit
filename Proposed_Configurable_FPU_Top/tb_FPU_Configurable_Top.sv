`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mohamed Adel Elshiemy
// 
// Create Date: 01/20/2026 09:12:00 AM
// Design Name: 
// Module Name: tb_FPU_Configurable_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_FPU_Configurable_Top;

    ////////////////////////////////////////////////////////////
    // DUT Inputs
    ////////////////////////////////////////////////////////////
    reg         clk;
    reg         reset;
    reg [1:0]   precision_sel;
    reg [3:0]   opcode;
    reg         data_valid;
    reg [31:0]  X_in;
    reg [31:0]  Y_in;

    ////////////////////////////////////////////////////////////
    // DUT Outputs
    ////////////////////////////////////////////////////////////
    wire [31:0] result_out;
    wire        ready;
    wire [1:0]  OFUF_out;
    wire [2:0]  compResult_out;

    ////////////////////////////////////////////////////////////
    // Instantiate DUT
    ////////////////////////////////////////////////////////////
    FPU_Configurable_Top DUT (
        .clk            (clk),
        .reset          (reset),
        .precision_sel  (precision_sel),
        .opcode         (opcode),
        .data_valid     (data_valid),
        .X_in           (X_in),
        .Y_in           (Y_in),
        .result_out     (result_out),
        .ready          (ready),
        .OFUF_out       (OFUF_out),
        .compResult_out (compResult_out)
    );

    ////////////////////////////////////////////////////////////
    // Clock Generation — 10 ns period (100 MHz)
    ////////////////////////////////////////////////////////////
    initial clk = 0;
    always #5 clk = ~clk;

    ////////////////////////////////////////////////////////////
    // Reset Sequence
    ////////////////////////////////////////////////////////////
    task apply_reset;
        begin
            reset = 1;
            precision_sel = 0;
            opcode = 0;
            data_valid = 0;
            X_in = 0;
            Y_in = 0;

            #40;   // hold reset
            reset = 0;
            #20;
        end
    endtask

    ////////////////////////////////////////////////////////////
    // Send FPU Operation
    ////////////////////////////////////////////////////////////
    task send_op(
        input [1:0] prec,
        input [3:0] op,
        input [31:0] A,
        input [31:0] B
    );
        begin
            precision_sel = prec;
            opcode = op;
            X_in = A;
            Y_in = B;
            data_valid = 1;
            #10;
            data_valid = 0;

            // Wait for ready
            wait (ready == 1);
            #10;
        end
    endtask

    ////////////////////////////////////////////////////////////
    // Print Result Helper
    ////////////////////////////////////////////////////////////
    task print_result;
        begin
            $display("[%0t ns] RESULT = %h | HP_OFUF=%b | HP_COMP=%b", 
                      $time, result_out, OFUF_out, compResult_out);
        end
    endtask

    ////////////////////////////////////////////////////////////
    // Half-Precision Conversion Helpers
    ////////////////////////////////////////////////////////////
    function [31:0] fp32;
        input real r;
        fp32 = $realtobits(r);
    endfunction

    ////////////////////////////////////////////////////////////
    // Test Sequences
    ////////////////////////////////////////////////////////////

    // ================================
    // Test 1: Half Precision ADD
    // ================================
    task test_hp_add;
        begin
            $display("\n=== TEST: HP ADD ===");
            send_op(2'b00, 4'b0001, 32'h3C00, 32'h4000);  
            // 0x3C00 = 1.0 (HP), 0x4000 = 2.0
            print_result();
        end
    endtask

    // ================================
    // Test 2: Half Precision MUL
    // ================================
    task test_hp_mul;
        begin
            $display("\n=== TEST: HP MUL ===");
            send_op(2'b00, 4'b0010, 32'h3C00, 32'h3C00);  
            print_result();
        end
    endtask

    // ================================
    // Test 3: Half Precision DIV
    // ================================
    task test_hp_div;
        begin
            $display("\n=== TEST: HP DIV ===");
            send_op(2'b00, 4'b0011, 32'h4000, 32'h3C00);
            // Expect 2.0 / 1.0 = 2.0
            print_result();
        end
    endtask

    // ================================
    // Test 4: Half Precision Comparator
    // ================================
    task test_hp_compare;
        begin
            $display("\n=== TEST: HP COMPARE ===");
            send_op(2'b00, 4'b0100, 32'h3C00, 32'h4000);  
            // 1.0 < 2.0
            print_result();
        end
    endtask

    // ================================
    // Test 5: Single Precision ADD
    // ================================
    task test_sp_add;
        begin
            $display("\n=== TEST: SP ADD ===");
            send_op(2'b01, 4'b0001, fp32(3.5), fp32(2.25));
            print_result();
        end
    endtask

    // ================================
    // Test 6: Single Precision MUL
    // ================================
    task test_sp_mul;
        begin
            $display("\n=== TEST: SP MUL ===");
            send_op(2'b01, 4'b0010, fp32(4.0), fp32(0.5));
            print_result();
        end
    endtask

    // ================================
    // Test 7: Single Precision DIV
    // ================================
    task test_sp_div;
        begin
            $display("\n=== TEST: SP DIV ===");
            send_op(2'b01, 4'b0011, fp32(10.0), fp32(4.0));
            print_result();
        end
    endtask

    // ================================
    // Test 8: Random Stress Testing
    // ================================
    task stress_test;
        integer i;
        real a, b;
        begin
            $display("\n=== RANDOM STRESS TEST (SP ADD) ===");
            for (i = 0; i < 20; i=i+1) begin
                a = $urandom_range(-5, 5) * 1.0;
                b = $urandom_range(-5, 5) * 1.0;
                send_op(2'b01, 4'b0001, fp32(a), fp32(b));
                $display("Input A=%f  B=%f => Result = %h", a, b, result_out);
            end
        end
    endtask

    ////////////////////////////////////////////////////////////
    // Testbench Main Control
    ////////////////////////////////////////////////////////////
    initial begin
        $display("============================================");
        $display("   CONFIGURABLE PRECISION FPU TESTBENCH");
        $display("============================================");

        apply_reset();

        test_hp_add();
        test_hp_mul();
        test_hp_div();
        test_hp_compare();

        test_sp_add();
        test_sp_mul();
        test_sp_div();

        stress_test();

        $display("\n=== ALL TESTS COMPLETED ===\n");
        #100;
        $finish;
    end

endmodule
