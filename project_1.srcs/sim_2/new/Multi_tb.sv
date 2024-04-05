`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 08:54:43 PM
// Design Name: 
// Module Name: Multiplexor_tb
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


module Multi_tb
#(
    parameter CLK_FREQUENCY = 200000000
);
    localparam T_CLK = 20; // ns
    
    logic [3:0]i_x = '0; logic[1:0] i_sel = 0;
    
    Lab1Multiplexor m0 (.i_x(i_x), .i_sel(i_sel));
    
    always #(T_CLK/2) i_x[3] <= !i_x[3];
    
    always #(1.5*T_CLK/2) i_x[2] <= !i_x[2];
    
    always #((T_CLK-5)/2) i_x[1] <= !i_x[1];
    
    always #(0.8*T_CLK/2) i_x[0] <= !i_x[0];
    
    always #(8*T_CLK) i_sel [1:0] = i_sel [1:0]+1;
    
endmodule

