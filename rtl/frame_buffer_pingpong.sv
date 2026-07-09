`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2026 06:09:55 PM
// Design Name: 
// Module Name: frame_buffer_pingpong
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


module frame_buffer_pingpong #(
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
    
    logic signed [WIDTH-1:0] f_mem0 [0:FRAME_SIZE-1]; // write 0, read 1 first
    logic signed [WIDTH-1:0] f_mem1 [0:FRAME_SIZE-1]; // write 1, read 0 after
    logic select_buffer; // 0 - write to mem0 and read from mem1, 1 - write to mem1 and read from mem0
    
    always_ff @(posedge clk) begin
        if (reset) begin
            f_ready <= 1'b0;
            select_buffer <= 1'b0;
        end else begin
            if (f_valid) begin
                if (!select_buffer) begin
                    f_mem0[sample_index] <= sample_in;
                end else begin
                    f_mem1[sample_index] <= sample_in;
                end
            end
            
            f_ready <= 1'b0;
            if (f_valid && sample_index == FRAME_SIZE-1) begin
                select_buffer <= ~select_buffer;
                f_ready <= 1'b1;
            end
        end
    end
    
    always_ff @(posedge clk) begin
        if (reset) begin
            read_data <= 'b0;
        end else begin
            if (read_en) begin
                if (select_buffer) begin
                    read_data <= f_mem0[read_addr];
                end else begin
                    read_data <= f_mem1[read_addr];
                end
            end
        end
    end
    
    
endmodule
