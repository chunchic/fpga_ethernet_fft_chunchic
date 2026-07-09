`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2026 06:14:49 PM
// Design Name: 
// Module Name: fft_test_1
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


module fft_test_1 #(
    parameter WIDTH = 16
) (
    input logic clk, reset,
    input logic signed [WIDTH-1:0] real_in, imag_in,
    input logic valid_in, start_in, end_in,
    
    output logic signed [WIDTH-1:0] real_out, imag_out,
    output logic valid_out, start_out, end_out
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            real_out <= 'b0;
            imag_out <= 'b0;
            valid_out <= 1'b0;
            start_out <= 1'b0;
            end_out <= 1'b0;
        end else begin
            real_out <= real_in + 1;
            imag_out <= 'b0;
            valid_out <= valid_in;
            start_out <= start_in;
            end_out <= end_in;
        end
    end
    
endmodule
