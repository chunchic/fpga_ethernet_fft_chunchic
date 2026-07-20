`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 08:40:36 AM
// Design Name: 
// Module Name: sine_tb
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


module square_tb(

    );
    
    reg clk = 1'b0;
    reg reset;
    always #5 clk = ~clk;
    
    reg [31:0] phase_inc;
    wire [15:0] square_out;
    
    initial begin
        $dumpfile("dds.vcd");
        $dumpvars(0, square_tb);
        
        phase_inc = 32'h028F5C29; // about 1 MHz at 100 MHz clock 
        // phase_inc = 1e6 * 2^32/1e8
        
        reset = 1'b1;
        #20;
        reset = 1'b0;
        
        
        
        #20000;

        
    //    $finish;
    end
    
    square square_DUT (
        .clk(clk),
        .reset(reset),
        .phase_inc(phase_inc),
        .square_out(square_out)
    );
    
    reg [31:0] phase_acc;
    always_comb begin
        phase_acc = square.phase_acc;
    end
    
endmodule
