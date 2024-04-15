`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2024 06:07:56 PM
// Design Name: 
// Module Name: tb_lab3_top
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


module tb_lab3_top(
    );
    
    bit i_clk = 1'b0; logic i_rst = '0; logic i_Ta='0; logic i_Tb='0;
    
    lab3_top u_sm (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_Ta(i_Ta),
    .i_Tb(i_Tb)
    );
    
    always #(5e2) i_clk = ~i_clk;
    
    always #(2.5e4) i_Ta = ~i_Ta;
    always #(7.1e4) i_Tb = ~i_Tb;
    
    initial begin i_rst = '0;
    
    #5 i_rst = 1'b1;
    #520 i_rst = 1'b0;
    end
endmodule