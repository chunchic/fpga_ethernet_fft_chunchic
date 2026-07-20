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


module sine_tb(

    );
    
    reg clk = 1'b0;
    reg reset;
    always #5 clk = ~clk;
    
    reg [31:0] phase_inc;
    wire [15:0] sine_out;
    
    initial begin
        $dumpfile("dds.vcd");
        $dumpvars(0, sine_tb);
        
        reset = 1'b1;
        phase_inc = 32'd0;
        #20;
        reset = 1'b0;
        
        phase_inc = 32'd100000;
        
        #2000;
        
        phase_inc = 32'd1000000;
        
        #2000;
        
    //    $finish;
    end
    
    sine sine_DUT (
        .clk(clk),
        .reset(reset),
        .phase_inc(phase_inc),
        .sine_out(sine_out)
    );
    
    
    reg [9:0] addr;
    reg [31:0] phase_acc;
    always_comb begin
        addr = sine.addr;
        phase_acc = sine.phase_acc;
    end
    
    
endmodule
