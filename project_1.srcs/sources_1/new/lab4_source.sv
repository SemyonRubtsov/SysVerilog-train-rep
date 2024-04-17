`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 07:50:02 PM
// Design Name: 
// Module Name: lab4_source
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


module lab4_source(
    input i_clk,                                                                 
    input i_rst,                                                              
                                                                               
    output m_axis_tvalid,            // output wire m_axis_tvalid       
    input m_axis_tready,            // input wire m_axis_tready        
    output [7:0] m_axis_tdata,              // output wire [7 : 0] m_axis_tdata
    output m_axis_tlast              // output wire m_axis_tlast         
    );
endmodule
