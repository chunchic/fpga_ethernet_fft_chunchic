`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2026 01:21:32 PM
// Design Name: 
// Module Name: frame_buffer
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


module frame_buffer #(
    parameter WIDTH = 16,
    parameter FRAME_SIZE = 1024,
    parameter ADDR_WIDTH = $clog2(FRAME_SIZE)
    )
    (
    input logic clk, reset,
    input logic signed [WIDTH-1:0] sample_in,
    input logic f_start, f_end, f_valid,
    input logic [ADDR_WIDTH-1:0] sample_index,
    input logic read_en,
    input logic [ADDR_WIDTH-1:0] read_addr,
    
    output logic signed [WIDTH-1:0] read_data,
    output logic f_ready
    );
    
    logic signed [WIDTH-1:0] f_mem [0:FRAME_SIZE-1];
    
    always_ff @(posedge clk) begin
        if (reset) begin
            f_ready <= 1'b0;
        end else begin
            if (f_valid) begin
                f_mem[sample_index] <= sample_in;
            end
            
            if (f_valid && sample_index == FRAME_SIZE-1) begin
                f_ready <= 1'b1;
            end else begin
                f_ready <= 1'b0;
            end
        end
    end
    
    always_ff @(posedge clk) begin
        if(read_en) begin
            read_data <= f_mem[read_addr];
        end
    end
    
endmodule
