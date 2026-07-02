`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 04:54:35 PM
// Design Name: 
// Module Name: sample_valid
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


module sample_valid #(
    parameter WIDTH = 16
)(
    input clk, reset,
    input signed [WIDTH-1:0] sample_in,
    input sample_in_valid,
    output logic signed [WIDTH-1:0] sample_out,
    output logic sample_out_valid
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            sample_out <= 'b0;
            sample_out_valid <= 1'b0;
        end else begin
            sample_out <= sample_in;
            sample_out <= sample_in_valid;
        end
    end
    
    
    
endmodule
