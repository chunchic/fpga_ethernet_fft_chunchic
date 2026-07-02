`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 04:06:35 PM
// Design Name: 
// Module Name: wave_gene_top
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


module wave_gene_top #(
    parameter WIDTH = 16
)

    (
    input [2:0] select,
    input signed [WIDTH-1:0] sine_in,
    input signed [WIDTH-1:0] square_in,
    input signed [WIDTH-1:0] triangle_in,
    input signed [WIDTH-1:0] saw_in,
    output logic signed [WIDTH-1:0] sample_out,
    output logic sample_out_valid
    );
    
    logic signed [WIDTH-1:0] sample;
    
    source_mux source_mux_inst (
        .select(select),
        .sine_in(sine_in),
        .square_in(square_in),
        .triangle_in(triangle_in),
        .saw_in(saw_in),
        .sample(sample)
    );
    
    sample_valid sample_valid_inst (
        .clk(clk),
        .reset(reset),
        .sample_in(sample),
        .sample_in_valid(1'b1),
        .sample_out(sample_out),
        .sample_out_valid(sample_out_valid)
    );
    
endmodule
