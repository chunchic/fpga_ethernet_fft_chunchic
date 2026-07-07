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


module wave_gen_top #(
    parameter WIDTH = 16,
    parameter FRAME_SIZE = 1024,
    parameter ADDR_WIDTH = $clog2(FRAME_SIZE)
)

    (
    input logic clk, reset,
    input logic [2:0] select,
    input logic signed [WIDTH-1:0] sine_in,
    input logic signed [WIDTH-1:0] square_in,
    input logic signed [WIDTH-1:0] triangle_in,
    input logic signed [WIDTH-1:0] saw_in,
    output logic signed [WIDTH-1:0] sample_out,
    output logic sample_out_valid
    );
    
    logic signed [WIDTH-1:0] sample;
    
    source_mux #(
        .WIDTH(WIDTH)
    )
    source_mux_inst  (
        .select(select),
        .sine_in(sine_in),
        .square_in(square_in),
        .triangle_in(triangle_in),
        .saw_in(saw_in),
        .sample(sample)
    );
    
    sample_valid #(
        .WIDTH(WIDTH)
    )
    sample_valid_inst (
        .clk(clk),
        .reset(reset),
        .sample_in(sample),
        .sample_in_valid(1'b1),
        .sample_out(sample_out),
        .sample_out_valid(sample_out_valid)
    );
    
    logic f_start, f_end, f_valid;
    logic [ADDR_WIDTH-1:0] sample_index;
    
    frame_counter #(
        .FRAME_SIZE(FRAME_SIZE)
    )   
    frame_counter_inst (
        .clk(clk),
        .reset(reset),
        .sample_valid(sample_out_valid),
        .sample_index(sample_index),
        .f_start(f_start),
        .f_end(f_end),
        .f_valid(f_valid)
    );
    
    logic [ADDR_WIDTH-1:0] read_addr;
    logic read_en;
    logic signed [WIDTH-1:0] read_data;
    logic f_ready;   
    
    frame_buffer #(
        .WIDTH(WIDTH),
        .FRAME_SIZE(FRAME_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH)
    )   
    frame_buffer_inst  (
        .clk(clk),
        .reset(reset),
        .sample_in(sample_out),
        .sample_index(sample_index),
        .f_start(f_start),
        .f_end(f_end),
        .f_valid(f_valid),
        
        .read_en(read_en),
        .read_addr(read_addr),
        .read_data(read_data),
        .f_ready(f_ready)
    );
    
    logic ctrl_valid, ctrl_start, ctrl_end;
    
    readout_controller #(
        .FRAME_SIZE(FRAME_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) readout_controller_inst (
        .clk(clk),
        .reset(reset),
        .f_ready(f_ready),
        .read_en(read_en),
        .read_addr(read_addr),
        .ctrl_valid(ctrl_valid),
        .ctrl_start(ctrl_start),
        .ctrl_end(ctrl_end)
    );
    
    logic [WIDTH-1:0] fft_real_out, fft_imag_out;
    logic fft_valid_out, fft_start_out, fft_end_out;
    
    fft_test_1 #(
        .WIDTH(WIDTH)
    ) fft_test_1_inst (
        .clk(clk),
        .reset(reset),
        .real_in(read_data),
        .imag_in('b0),
        .valid_in(ctrl_valid),
        .start_in(ctrl_start),
        .end_in(ctrl_end),
        .real_out(fft_real_out),
        .imag_out(fft_imag_out),
        .valid_out(fft_valid_out),
        .start_out(fft_start_out),
        .end_out(fft_end_out)
    );
    
endmodule
