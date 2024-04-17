`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 07:50:02 PM
// Design Name: 
// Module Name: lab4_dest
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


module lab4_dest(
    input i_clk,
    input i_rst,
   
    input s_axis_tvalid,            // input wire s_axis_tvalid
    output s_axis_tready,            // output wire s_axis_tready
    input [7:0] s_axis_tdata,              // input wire [7 : 0] s_axis_tdata
    input s_axis_tlast              // input wire s_axis_tlast
    );
endmodule
