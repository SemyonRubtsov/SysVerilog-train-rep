`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 03:40:29 AM
// Design Name: 
// Module Name: lab4_shiftreg
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


module lab4_shiftreg
#(
    parameter PACKET_LEN = 12
)
(
    input logic i_clk,
    input byte i_data,
    input logic i_reg_vld,
    output logic o_data_vld,
    output byte o_data
);
    
    //parameter shift = 12;

    reg [0:3] m_cnt = '0;
    reg [PACKET_LEN-1:0][8-1:0] m_shiftreg = {PACKET_LEN{1'b0}};

    always @(posedge i_clk) begin
        if (i_reg_vld) begin
        m_shiftreg  <= {i_data, m_shiftreg[PACKET_LEN-1:1]};
        
        if (m_cnt==PACKET_LEN-2)
            o_data_vld<='0;
        
        if (m_cnt==1) o_data_vld<='1; // temporary, must be fixed
        
        if (m_cnt<PACKET_LEN-1)
            m_cnt<=m_cnt+1;
        else begin
            m_cnt<=0;
            //o_data_vld<='1;
        end
        
        end
        
    end
    
    assign o_data = m_shiftreg[0];
    
endmodule
