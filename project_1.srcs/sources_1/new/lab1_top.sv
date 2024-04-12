`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 08:19:34 PM
// Design Name: 
// Module Name: Lab1Multiplexor
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


module lab1_top
#(
    parameter INPUT_WIDTH=4
)
(
    input logic [4:0] i_x,
    input logic [2:0] i_sel,
    output logic o_f
);

lab1_mux #(.INPUT_WIDTH(INPUT_WIDTH)) u_mux (.i_x(i_x),.i_sel(i_sel),.o_f(o_f));

endmodule
