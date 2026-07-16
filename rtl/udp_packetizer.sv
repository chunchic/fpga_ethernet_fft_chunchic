`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2026 05:44:24 PM
// Design Name: 
// Module Name: udp_packetizer
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


module udp_packetizer #(
    parameter logic [47:0] DEST_MAC = 48'h0011_2233_4455,
    parameter logic [47:0] SRC_MAC = 48'h6677_8899_AABB,
    parameter logic [31:0] SRC_IP   = 32'hC0A8_010A, // 192.168.1.10
    parameter logic [31:0] DEST_IP  = 32'hC0A8_010B, // 192.168.1.11
    parameter logic [15:0] SRC_PORT  = 16'd5000,
    parameter logic [15:0] DEST_PORT = 16'd5001,

    parameter integer PAYLOAD_BYTES = 1024,
    parameter integer PACKETS_PER_FRAME = 4
 )   (
    
    input logic clk, reset,
    input logic [7:0] s_axis_tdata,
    input logic s_axis_tvalid, s_axis_tlast,
    output logic s_axis_tready,
    
    output logic [7:0] m_axis_tdata,
    output logic m_axis_tvalid, m_axis_tlast,
    input logic m_axis_tready
    
    );
    
     localparam logic [15:0] IP_TOTAL_LENGTH =
        16'(20 + 8 + PAYLOAD_BYTES);

    localparam logic [15:0] UDP_LENGTH =
        16'(8 + PAYLOAD_BYTES);

    typedef enum logic [2:0] {IDLE,ETH_HEADER,IP_HEADER,UDP_HEADER,PAYLOAD} state_t;

    state_t state;

    logic [4:0]  header_counter;
    logic [10:0] payload_counter;
    logic [1:0]  packet_counter;

    logic output_transfer; 
    logic input_transfer;

    assign output_transfer = m_axis_tvalid && m_axis_tready;
    assign input_transfer  = s_axis_tvalid && s_axis_tready;

    function automatic logic [15:0] calculate_ip_checksum;
    logic [31:0] sum;
    begin
       
        sum = 32'd0;
        sum = sum + 16'h4500; // byte 0: 0x45 (4 is IPv4, 5 is IPv4 header length)   
        sum = sum + IP_TOTAL_LENGTH; // full IPv4 total packet length
        sum = sum + 16'h0000; // identification (only used when packet is fragmented)
        sum = sum + 16'h4000; // 16'b0100000000000000 means dont fragment bit = 1
        sum = sum + 16'h4011; // 0x40 = 64 - TTL, 0x11 = 17 - UDP
        
        sum = sum + SRC_IP[31:16];
        sum = sum + SRC_IP[15:0];
        sum = sum + DEST_IP[31:16];
        sum = sum + DEST_IP[15:0];
        
        sum = sum[15:0] + sum[31:16]; 
        sum = sum[15:0] + sum[31:16]; // fold twice because the first fold can produce an extra carry
        calculate_ip_checksum = ~sum[15:0]; // checksum is ones complement of sum
        
    end
    endfunction

    localparam logic [15:0] IP_CHECKSUM = calculate_ip_checksum(); // calculating checksum during synthesis because its just a constant
    
    always_comb begin
        m_axis_tdata = 'b0;
        m_axis_tvalid = 1'b0;
        m_axis_tlast = 1'b0;
        s_axis_tready = 1'b0;
        
        case (state)
            IDLE: begin
                // nothing here
                // s_axis_tvalid starts transmission
            end
        
            ETH_HEADER: begin
                m_axis_tvalid = 1'b1;
                
                case (header_counter)
                    0:  m_axis_tdata = DEST_MAC[47:40];
                    1:  m_axis_tdata = DEST_MAC[39:32];
                    2:  m_axis_tdata = DEST_MAC[31:24];
                    3:  m_axis_tdata = DEST_MAC[23:16];
                    4:  m_axis_tdata = DEST_MAC[15:8];
                    5:  m_axis_tdata = DEST_MAC[7:0];

                    6:  m_axis_tdata = SRC_MAC[47:40];
                    7:  m_axis_tdata = SRC_MAC[39:32];
                    8:  m_axis_tdata = SRC_MAC[31:24];
                    9:  m_axis_tdata = SRC_MAC[23:16];
                    10: m_axis_tdata = SRC_MAC[15:8];
                    11: m_axis_tdata = SRC_MAC[7:0];

                    12: m_axis_tdata = 8'h08;
                    13: m_axis_tdata = 8'h00;
                    default: m_axis_tdata = 8'h00;
                endcase
            end    
            
            IP_HEADER: begin
                m_axis_tvalid = 1'b1;
                
                 case (header_counter)
                    0:  m_axis_tdata = 8'h45;
                    1:  m_axis_tdata = 8'h00;

                    2:  m_axis_tdata = IP_TOTAL_LENGTH[15:8];
                    3:  m_axis_tdata = IP_TOTAL_LENGTH[7:0];

                    4:  m_axis_tdata = 8'h00;
                    5:  m_axis_tdata = 8'h00;

                    6:  m_axis_tdata = 8'h40;
                    7:  m_axis_tdata = 8'h00;

                    8:  m_axis_tdata = 8'h40;
                    9:  m_axis_tdata = 8'h11;

                    10: m_axis_tdata = IP_CHECKSUM[15:8];
                    11: m_axis_tdata = IP_CHECKSUM[7:0];

                    12: m_axis_tdata = SRC_IP[31:24];
                    13: m_axis_tdata = SRC_IP[23:16];
                    14: m_axis_tdata = SRC_IP[15:8];
                    15: m_axis_tdata = SRC_IP[7:0];

                    16: m_axis_tdata = DEST_IP[31:24];
                    17: m_axis_tdata = DEST_IP[23:16];
                    18: m_axis_tdata = DEST_IP[15:8];
                    19: m_axis_tdata = DEST_IP[7:0];

                    default: m_axis_tdata = 8'h00;
                endcase
            end
            
            UDP_HEADER: begin
                m_axis_tvalid = 1'b1;

                case (header_counter)
                    0: m_axis_tdata = SRC_PORT[15:8];
                    1: m_axis_tdata = SRC_PORT[7:0];

                    2: m_axis_tdata = DEST_PORT[15:8];
                    3: m_axis_tdata = DEST_PORT[7:0];

                    4: m_axis_tdata = UDP_LENGTH[15:8];
                    5: m_axis_tdata = UDP_LENGTH[7:0];

                    // UDP checksum disabled for IPv4
                    6: m_axis_tdata = 8'h00;
                    7: m_axis_tdata = 8'h00;

                    default: m_axis_tdata = 8'h00;
                endcase
            end
            
            PAYLOAD: begin
                m_axis_tdata  = s_axis_tdata;
                m_axis_tvalid = s_axis_tvalid;
                s_axis_tready = m_axis_tready;

                if (payload_counter == PAYLOAD_BYTES - 1)
                    m_axis_tlast = 1'b1;
            end

            default: begin
            end
            
        endcase 
        
        
    end
    
    
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            header_counter <= 0;
            payload_counter <= 0;
            packet_counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    header_counter <= 0;
                    payload_counter <= 0;
                    packet_counter <= 0;
                    
                    if (s_axis_tvalid) begin
                        state <= ETH_HEADER;
                    end
                end
                
                ETH_HEADER: begin
                    if (output_transfer) begin // master valid and ready
                        if (header_counter == 13) begin
                            header_counter <= 0;
                            state <= IP_HEADER;
                        end else begin
                            header_counter <= header_counter + 1;
                        end
                    end
                end
                
                IP_HEADER: begin
                    if (output_transfer) begin
                        if (header_counter == 19) begin
                            header_counter <= 0;
                            state <= UDP_HEADER;
                        end else begin
                            header_counter <= header_counter + 1;
                        end
                    end
                end
                
                UDP_HEADER: begin
                    if (output_transfer) begin
                        if (header_counter == 7) begin
                            header_counter <= 0;
                            payload_counter <= 0;
                            state <= PAYLOAD;
                        end else begin
                            header_counter <= header_counter + 1;
                        end
                    end
                end
                
                PAYLOAD: begin
                    if (input_transfer) begin
                        if (payload_counter == PAYLOAD_BYTES - 1) begin
                            payload_counter <= 0;
                            
                            if (packet_counter == PACKETS_PER_FRAME - 1) begin
                                packet_counter <= 0;
                                state <= IDLE;
                            end else begin
                                packet_counter <= packet_counter + 1;
                                header_counter <= 0;
                                state <= ETH_HEADER;
                            end
                            
                        end else begin
                            payload_counter <= payload_counter + 1;
                        end
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
                
            endcase 
        end
    end
    
endmodule
