`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2024 08:04:13 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: bv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Lab2top
#(
    parameter CLK_FREQUENCY = 200000000, // Гц
    parameter BLINK_PERIOD = 1 // секунды
)
(
    input wire clk_in1_p,
    input wire clk_in1_n,
    (* MARK_DEBUG="true" *) input wire [1:0] i_rst,
    (* MARK_DEBUG="true" *) output logic [7:0] o_led
    //output wire i_clk
);

wire i_clk;

clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(i_clk),     // output clk_out1
    // Status and control signals
    //.reset(i_rst), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1_p(clk_in1_p),    // input clk_in1_p
    .clk_in1_n(clk_in1_n)
    );    // input clk_in1_n

led_4# ( .CLK_FREQUENCY(CLK_FREQUENCY),
    .BLINK_PERIOD (BLINK_PERIOD),
    .OUT_WIDTH(1))
    l0[1:0] (.i_clk(i_clk),.i_rst(i_rst),.o_led(o_led));

endmodule

