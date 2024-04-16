`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2024 05:40:16 PM
// Design Name: 
// Module Name: lab3_top
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



module lab3_traffic_top(
    input wire clk_in1_p,
    input wire clk_in1_n,
    input i_rst,
    input i_Ta,
    input i_Tb,
    output reg [2:0] o_La,
    output reg [2:0] o_Lb
    );
    
    wire m_clk;
    
    clk_wiz_0 u_pll
   (
    // Clock out ports
    .clk_out1(m_clk),     // output clk_out1
    // Status and control signals
    .reset('0), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1_p(clk_in1_p),    // input clk_in1_p
    .clk_in1_n(clk_in1_n)
    );    // input clk_in1_n
    
    lab3_top u_sm(
    .i_clk(m_clk),
    .i_rst(i_rst),
    .i_Ta(i_Ta),
    .i_Tb(i_Tb),
    .o_La(o_La),
    .o_Lb(o_Lb)
    );
    
    
endmodule