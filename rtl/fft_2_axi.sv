`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 04:42:26 PM
// Design Name: 
// Module Name: fft_2_axi
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


module fft_2_axi #(
    parameter WIDTH = 16
)   (
    input logic clk, reset,
    input logic signed [WIDTH-1:0] fft_real_out, fft_imag_out,
    input logic fft_valid_out, fft_start_out, fft_end_out,
    
    output logic [2*WIDTH-1:0] m_axis_tdata,
    output logic m_axis_tvalid, m_axis_tlast, m_axis_tready
    );
    
    wire register_ready;
    assign register_ready = !m_axis_tvalid || m_axis_tready;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            m_axis_tdata <= 'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast <= 1'b0;
        end else if (register_ready) begin
            if (fft_valid_out) begin
                m_axis_tvalid <= fft_valid_out;
                m_axis_tlast <= fft_end_out;
                m_axis_tdata <= {fft_real_out,fft_imag_out};
            end else begin
                m_axis_tdata <= 'b0;
                m_axis_tvalid <= 1'b0;
                m_axis_tlast <= 1'b0;    
            end
            
            
        end
    end
    
endmodule
