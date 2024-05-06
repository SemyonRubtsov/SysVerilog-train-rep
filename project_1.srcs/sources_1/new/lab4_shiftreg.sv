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
    input logic i_rst,
    input byte i_data,
    input logic i_reg_vld,
    output logic o_data_vld,
    output logic o_data_tlast,
    output byte o_data
);
    
    //parameter shift = 12;

    reg [0:3] m_cnt = '0;
    reg [PACKET_LEN-1:0][8-1:0] m_shiftreg = {PACKET_LEN{1'b0}};

    //always @(negedge i_reg_vld) begin
        //m_cnt<=0;
    //end

    always @(posedge i_reg_vld) begin
        if (m_shiftreg[0]==72) o_data_vld<='1;
        if (m_cnt==PACKET_LEN-1) m_cnt<=0;
    end

    always @(posedge i_clk) begin
    
        if (i_rst) begin
            m_cnt=0;
            m_shiftreg='0;
            o_data_vld='0;
            o_data_tlast='0;
            o_data='0;
            //m_shiftreg must be reseted?
        end
    
        if (i_reg_vld) begin
        m_shiftreg  <= {i_data, m_shiftreg[PACKET_LEN-1:1]};
        
        if (m_cnt<PACKET_LEN-1)
            m_cnt<=m_cnt+1;
        else begin
            m_cnt<=0;
            //o_data_vld<='1;
        end
        
        end
        
        //if (i_reg_vld & m_cnt==0) o_data_vld<='1; // temporary, must be fixed
        
        o_data_tlast<='0;
        
        if (m_cnt==PACKET_LEN | !i_reg_vld) begin
            o_data_vld<='0;
        end
        
        if (m_cnt==PACKET_LEN-1)
            o_data_tlast<='1;
    end
    
    assign o_data = m_shiftreg[0];
    
endmodule
