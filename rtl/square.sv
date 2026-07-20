`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 03:23:41 PM
// Design Name: 
// Module Name: square
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


module square #(
    parameter int WIDTH = 16,
    parameter int PHASE_WIDTH = 32
)

    (
    input clk, reset,
    
    input [PHASE_WIDTH-1:0] phase_inc,
    output logic signed [WIDTH-1:0] square_out
    );
    
    logic [PHASE_WIDTH-1:0] phase_acc;
    localparam pos_amp = 16'sd1000;
    localparam neg_amp = -16'sd1000;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            phase_acc <= 'b0;
            square_out <= 'b0;
        end else begin
            phase_acc <= phase_acc + phase_inc;
            if (phase_acc[PHASE_WIDTH-1]) begin
                square_out <= pos_amp;
            end else begin
                square_out <= neg_amp;
            end
        end
    end
    
endmodule
