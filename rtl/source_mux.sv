`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 04:53:02 PM
// Design Name: 
// Module Name: source_mux
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


module source_mux #(
    parameter WIDTH = 16
)

    (
    input [2:0] select,
    input signed [WIDTH-1:0] sine_in,
    input signed [WIDTH-1:0] square_in,
    input signed [WIDTH-1:0] triangle_in,
    input signed [WIDTH-1:0] saw_in,
    output logic signed [WIDTH-1:0] sample
    );
    
    always_comb begin
        case(select)
        3'd0: sample = sine_in;
        3'd1: sample = square_in;
        3'd2: sample = triangle_in;
        3'd3: sample = saw_in;
        default: sample = sine_in;
        endcase
    end

endmodule