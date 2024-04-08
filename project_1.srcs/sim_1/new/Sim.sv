`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2024 08:32:03 PM
// Design Name: 
// Module Name: Sim
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

module Sim
#(
    parameter CLK_FREQUENCY = 1e9, parameter BLINK_PERIOD = 1e-5//0.0001
);
//-- Constants
    localparam T_CLK = 1.0e9 / CLK_FREQUENCY; // ns
//-- Signals
    bit i_clk = 1'b0; bit i_rst = 1'b0; bit i_rst = 1'b0;
//-- 
    Lab2top# ( .CLK_FREQUENCY(CLK_FREQUENCY),
    .BLINK_PERIOD (BLINK_PERIOD))
    UUT_2 (
    .clk_in1_p (i_clk),
    .clk_in1_n (!i_clk),
    .i_rst(i_rst)
    );
    //.o_led ());
//--
    always #(T_CLK/2) i_clk = ~i_clk;
    initial begin i_rst = 1'b0;
    #10e3 i_rst = 1'b0; #10000 i_rst = 1'b0; #10100 i_rst = 1'b0;
    end
endmodule
