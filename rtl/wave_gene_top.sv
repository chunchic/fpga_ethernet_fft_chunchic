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
    output logic signed [WIDTH-1:0] fft_real_out, fft_imag_out,
    output logic fft_valid_out, fft_start_out, fft_end_out
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
    
    logic signed [WIDTH-1:0] sample_out_formatted;
    logic sample_out_valid;
    
    sample_valid #(
        .WIDTH(WIDTH)
    )
    sample_valid_inst (
        .clk(clk),
        .reset(reset),
        .sample_in(sample),
        .sample_in_valid(1'b1),
        .sample_out_formatted(sample_out_formatted),
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
    
    frame_buffer_pingpong #(
        .WIDTH(WIDTH),
        .FRAME_SIZE(FRAME_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH)
    )   
    frame_buffer_inst  (
        .clk(clk),
        .reset(reset),
        .sample_in(sample_out_formatted),
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
    
    readout_controller_pingpong #(
        .FRAME_SIZE(FRAME_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) readout_controller_inst (
        .clk(clk),
        .reset(reset),
        .f_ready(f_ready),
        .sample_index(sample_index),
        .read_en(read_en),
        .read_addr(read_addr),
        .ctrl_valid(ctrl_valid),
        .ctrl_start(ctrl_start),
        .ctrl_end(ctrl_end)
    );
    
//    logic [WIDTH-1:0] fft_real_out, fft_imag_out;
//    logic fft_valid_out, fft_start_out, fft_end_out;
    
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
    
    logic [ADDR_WIDTH-1:0] out_counter1, stream_counter;
    logic [WIDTH*2-1:0] stream_data;
    
    assign stream_data = {fft_real_out,fft_imag_out};
    always_ff @(posedge clk) begin
        if (reset) begin
            out_counter1 <= 0;
            stream_counter <= 0;
        end else begin
            out_counter1 <= read_addr;
            stream_counter <= out_counter1;
        end
    end
    
    logic [2*WIDTH-1:0] fifo_s_axis_tdata;
    logic fifo_s_axis_tvalid, fifo_s_axis_tlast, fifo_s_axis_tready;
    
    fft_2_axi #(
        .WIDTH(WIDTH)
    ) fft_2_axi_inst (
        .clk(clk),
        .reset(reset),
        .fft_real_out(fft_real_out),
        .fft_imag_out(fft_imag_out),
        .fft_valid_out(fft_valid_out),
        .fft_start_out(fft_start_out),
        .fft_end_out(fft_end_out),
        .m_axis_tdata(fifo_s_axis_tdata),
        .m_axis_tvalid(fifo_s_axis_tvalid),
        .m_axis_tlast(fifo_s_axis_tlast),
        .m_axis_tready(fifo_s_axis_tready)
    );
    
    logic fifo_m_axis_tvalid, fifo_m_axis_tready, fifo_m_axis_tlast;
    logic [2*WIDTH-1:0] fifo_m_axis_tdata;
    
    
    // axi4-stream data fifo IP
 axis_data_fifo_0 axis_data_fifo_0_inst (
  .s_axis_aresetn(~reset),  // input wire s_axis_aresetn
  .s_axis_aclk(clk),        // input wire s_axis_aclk
  .s_axis_tvalid(fifo_s_axis_tvalid),    // input wire s_axis_tvalid
  .s_axis_tready(fifo_s_axis_tready),    // output wire s_axis_tready
  .s_axis_tdata(fifo_s_axis_tdata),      // input wire [31 : 0] s_axis_tdata
  .s_axis_tlast(fifo_s_axis_tlast),      // input wire s_axis_tlast
  .m_axis_tvalid(fifo_m_axis_tvalid),    // output wire m_axis_tvalid
  .m_axis_tready(fifo_m_axis_tready),    // input wire m_axis_tready
  .m_axis_tdata(fifo_m_axis_tdata),      // output wire [31 : 0] m_axis_tdata
  .m_axis_tlast(fifo_m_axis_tlast)      // output wire m_axis_tlast
);
    
    logic conv_m_axis_tvalid, conv_m_axis_tready, conv_m_axis_tlast;
    logic [7:0] conv_m_axis_tdata;
    
    // axi4-stream data width converter 32 bit -> 8 bit for ethernet
axis_dwidth_converter_0 axis_dwidth_converter_0_inst (
  .aclk(clk),                    // input wire aclk
  .aresetn(~reset),              // input wire aresetn
  .s_axis_tvalid(fifo_m_axis_tvalid),  // input wire s_axis_tvalid
  .s_axis_tready(fifo_m_axis_tready),  // output wire s_axis_tready
  .s_axis_tdata(fifo_m_axis_tdata),    // input wire [31 : 0] s_axis_tdata
  .s_axis_tlast(fifo_m_axis_tlast),    // input wire s_axis_tlast
  .m_axis_tvalid(conv_m_axis_tvalid),  // output wire m_axis_tvalid
  .m_axis_tready(conv_m_axis_tready),  // input wire m_axis_tready
  .m_axis_tdata(conv_m_axis_tdata),    // output wire [7 : 0] m_axis_tdata
  .m_axis_tlast(conv_m_axis_tlast)    // output wire m_axis_tlast
);
    
    logic udp_m_axis_tvalid, udp_m_axis_tready, udp_m_axis_tlast;
    logic [7:0] udp_m_axis_tdata;
    assign udp_m_axis_tready = 1'b1;
    
udp_packetizer  #(
    .PAYLOAD_BYTES(4 * FRAME_SIZE),
    .PACKETS_PER_FRAME(1)
)  udp_packetizer_inst  (
    .clk(clk),
    .reset(reset),
    .s_axis_tvalid(conv_m_axis_tvalid),
    .s_axis_tready(conv_m_axis_tready),
    .s_axis_tdata(conv_m_axis_tdata),
    .s_axis_tlast(conv_m_axis_tlast),
    .m_axis_tvalid(udp_m_axis_tvalid),
    .m_axis_tready(udp_m_axis_tready),
    .m_axis_tdata(udp_m_axis_tdata),
    .m_axis_tlast(udp_m_axis_tlast)
);
    
endmodule
