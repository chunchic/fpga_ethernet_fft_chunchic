`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2026 04:26:04 PM
// Design Name: 
// Module Name: wave_gen_top_tb
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


module wave_gen_top_tb(

    );
    
    parameter WIDTH = 16;
    parameter FRAME_SIZE = 16;
    parameter ADDR_WIDTH = $clog2(FRAME_SIZE);
    
    logic clk = 1'b0;
    logic reset;
    logic [2:0] select;
    
    always #5 clk = ~clk;
    
    logic signed [WIDTH-1:0] sine_in, square_in, triangle_in, saw_in;
    logic signed [31:0] phase_inc;
    
    
    initial begin
        $dumpfile("wgt.vcd");
        $dumpvars(0,wave_gen_top_tb);
        
        reset = 1'b1;
        select = 3'd0; // sine
        triangle_in = 'b0;
        saw_in = 'b0;
        phase_inc = 32'b0;
        
        #(40);
        reset = 1'b0;
        phase_inc = 32'd100000000;
        
        #(20000);
        
        select = 3'd1; // square
        
        #(20000);
        
        $stop;
        
    end
    
    sine sine_inst (
        .clk(clk),
        .reset(reset),
        .phase_inc(phase_inc),
        .sine_out(sine_in)
    );
    
    square square_inst (
        .clk(clk),
        .reset(reset),
        .phase_inc(phase_inc),
        .square_out(square_in)
    );
    
    logic signed [WIDTH-1:0] fft_real_out, fft_imag_out;
    logic fft_valid_out, fft_start_out, fft_end_out;
    
    wave_gen_top #(
        .WIDTH(WIDTH),
        .FRAME_SIZE(FRAME_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) wave_gen_top_inst (
        .clk(clk),
        .reset(reset),
        .select(select),
        .sine_in(sine_in),
        .square_in(square_in),
        .triangle_in(triangle_in),
        .saw_in(saw_in),
        .fft_real_out(fft_real_out),
        .fft_imag_out(fft_imag_out),
        .fft_valid_out(fft_valid_out),
        .fft_start_out(fft_start_out),
        .fft_end_out(fft_end_out)
    );
    
    
    
endmodule
