`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2026 06:27:50 PM
// Design Name: 
// Module Name: readout_controller_pingpong
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


module readout_controller_pingpong #(
    parameter FRAME_SIZE = 1024,
    parameter ADDR_WIDTH = $clog2(FRAME_SIZE)
)(
    input logic clk, reset,
    
    input logic f_ready,
    input logic [ADDR_WIDTH-1:0] sample_index,
    output logic read_en,
    output logic [ADDR_WIDTH-1:0] read_addr,
    output logic ctrl_valid, ctrl_start, ctrl_end
    );
    
    logic read_state;
   
    always_ff @(posedge clk) begin
        if (reset) begin
            read_state <= 1'b0;
        end else begin
            if (f_ready) begin
                read_state <= 1'b1;
            end
        end
    end

    assign read_en = read_state;
    assign read_addr = sample_index;
    assign ctrl_valid = read_state;
    assign ctrl_start = read_state && (sample_index == 0);
    assign ctrl_end = read_state && (FRAME_SIZE-1);

endmodule
