`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 05:58:06 PM
// Design Name: 
// Module Name: frame_counter
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
// FFT frame counter just need 1024 samples
// count when sample_valid is 1


module frame_counter #(
    parameter FRAME_SIZE = 1024
)(
    input logic clk, reset,
    input logic sample_valid,
    output logic [9:0] sample_index,
    output logic f_start, f_end, f_valid     
    );
    
    logic [9:0] counter;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            sample_index <= 0;
            f_start <= 1'b0;
            f_end <= 1'b0;
            f_valid <= 1'b0;
        end else begin
            if (sample_valid) begin
                sample_index <= counter; 
                // using internal counter to remove the lag between sample_index and f_start/f_end
                f_valid <= 1'b1;
                if (counter == 0) begin
                    f_start <= 1'b1;
                    f_end <= 1'b0;
                    counter <= counter + 1;
                end else if (counter == FRAME_SIZE - 1) begin
                    f_start <= 1'b0;
                    f_end <= 1'b1;
                    counter <= 0;
                end else begin
                    f_start <= 1'b0;
                    f_end <= 1'b0;
                    counter <= counter + 1;
                end
                
            end else begin
                f_start <= 1'b0;
                f_end <= 1'b0;
                f_valid <= 1'b0;
            end
        end
    end
    
    
endmodule
