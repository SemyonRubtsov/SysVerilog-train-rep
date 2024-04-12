`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2024 10:30:00 PM
// Design Name: 
// Module Name: SimMuxLed
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


module tb_lab2_ind_top
#(
    parameter CLK_FREQUENCY = 200000000,
    parameter real BLINK_PERIOD =1e-4
);
//-- Constants
    localparam T_CLK = 1.0e9 / CLK_FREQUENCY; // ns
//-- Signals
    bit i_clk = 1'b0; logic i_rst = '0;
//-- 
    lab2_ind_top#
        (.CLK_FREQUENCY(CLK_FREQUENCY),
        .BLINK_PERIOD (BLINK_PERIOD),
        .OUT_WIDTH (4))
    UUT_2 (
        .clk_in1_p (i_clk),
        .clk_in1_n (!i_clk),
        .i_rst(i_rst)
    );
    //.o_led ());
//--
    always #(T_CLK*1000000) i_rst <= i_rst+1;
    always #(T_CLK/2) i_clk = ~i_clk;
    //initial begin i_rst = '1;
    //#10e3 i_rst = 1'b0;
    //#10000 i_rst = 1'b1;
    //#250000 i_rst = '0;
    //end
endmodule