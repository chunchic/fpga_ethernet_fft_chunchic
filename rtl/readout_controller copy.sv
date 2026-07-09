`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2026 03:24:26 PM
// Design Name: 
// Module Name: readout_controller
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


module readout_controller #(
    parameter FRAME_SIZE = 1024,
    parameter ADDR_WIDTH = $clog2(FRAME_SIZE)
)(
    input logic clk, reset,
    
    input logic f_ready,
    output logic read_en,
    output logic [ADDR_WIDTH-1:0] read_addr,
    output logic ctrl_valid, ctrl_start, ctrl_end
    );
    
    typedef enum logic {IDLE, READ} state_t;
    state_t state;
    
    logic [ADDR_WIDTH-1:0] counter;
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            counter <= 'b0;
            read_en <= 1'b0;
            read_addr <= 'b0;
            ctrl_valid <= 1'b0;
            ctrl_start <= 1'b0;
            ctrl_end <= 1'b0;
        end else begin    
            case(state)
                IDLE: begin
                    counter <= 'b0;
                    read_en <= 1'b0;
                    read_addr <= 'b0;
                    ctrl_valid <= 1'b0;
                    ctrl_start <= 1'b0;
                    ctrl_end <= 1'b0;
                    if (f_ready) begin
                        state <= READ;
                    end
                end
                
                READ: begin
                    read_en <= 1'b1;
                    read_addr <= counter;
                    ctrl_valid <= 1'b1;
                    
                    if (counter == 'b0) begin
                        ctrl_start <= 1'b1;
                    end else begin
                        ctrl_start <= 1'b0;
                    end
                    
                    if (counter == FRAME_SIZE-1) begin
                        counter <= 'b0;
                        ctrl_end <= 1'b1;
                        state <= IDLE;                   
                    end else begin
                        counter <= counter + 1;
                        ctrl_end <= 1'b0;
                    end
                    
                end
            endcase
        end
    end
    
endmodule
