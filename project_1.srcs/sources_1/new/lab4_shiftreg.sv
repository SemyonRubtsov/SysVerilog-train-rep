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


module lab4_shiftreg(
    input byte i_data,
    input logic i_clk,
    input logic i_reg_vld,
    output byte o_data
    );
    
    parameter shift = 12;

    reg [shift-1:0][8-1:0] m_shiftreg = {shift{1'b0}};

    always @(posedge i_clk & i_reg_vld)
        m_shiftreg  <= {i_data, m_shiftreg[shift-1:1]};

    assign o_data = m_shiftreg[0];
    
endmodule
