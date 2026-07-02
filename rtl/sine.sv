`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 08:21:15 AM
// Design Name: 
// Module Name: sine
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


module sine(
    input clk, reset,
    input [31:0] phase_inc,
    output reg signed [15:0] sine_out
    );
    
    reg [31:0] phase_acc; // phase accumulator 
    // LUT size 10 bits. 2^10 = 1024 samples per period
    wire [9:0] addr;
    
    reg signed [15:0] sine_rom [0:1023];
    assign addr = phase_acc[31:22]; // reading top 10 bits from phase accumulator;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            phase_acc <= 0;
        end else begin
            phase_acc <= phase_acc + phase_inc;
        end
    end
    
    always @(posedge clk) begin
        sine_out <= sine_rom[addr];
    end
    
    initial begin
        $readmemh("sine_values.mem",sine_rom);
    end
    
endmodule
