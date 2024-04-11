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


module SimMuxLed
#(
    parameter CLK_FREQUENCY = 200000000,
    parameter bit [3:0][31:0] BLINK_PERIOD = {32'd200_000_000, 32'd100_000_000 , 32'd50_000_000, 32'd25_000_000}
);
//-- Constants
    localparam T_CLK = 1.0e9 / CLK_FREQUENCY; // ns
//-- Signals
    bit i_clk = 1'b0; logic [1:0] i_rst = '0;
//-- 
    MUX_LED_Top# ( .CLK_FREQUENCY(CLK_FREQUENCY),
    .BLINK_PERIOD (BLINK_PERIOD))
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
