`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 07:35:10 PM
// Design Name: 
// Module Name: frame_counter_tb
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


module frame_counter_tb(

    );
    
    logic clk = 1'b0; 
    logic reset;
    logic sample_valid;
    logic [9:0] sample_index;
    logic f_start, f_valid, f_end;
    
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("dds.vcd");
        $dumpvars(0, frame_counter_tb);
        
        reset = 1'b1;
        sample_valid = 1'b0;
        #20;
        reset = 1'b0;
        sample_valid = 1'b1;
        
        #20000;
    end 
    
    frame_counter frame_counter_DUT (
        .clk(clk),
        .reset(reset),
        .sample_valid(sample_valid),
        .sample_index(sample_index),
        .f_start(f_start),
        .f_valid(f_valid),
        .f_end(f_end)
    );
    
endmodule
