`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 06:15:34 PM
// Design Name: 
// Module Name: lab2b_top
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


module lab2b_top
#(
    parameter CLK_FREQUENCY = 200000000, // Гц
    parameter real BLINK_PERIOD [3:0] = {2, 1 , 0.5, 0.25} // секунды
)
(
    input wire clk_in1_p,
    input wire clk_in1_n,
    input wire [1:0] i_rst,
    output wire [3:0] o_led
    //output wire i_clk
);

wire i_clk;

wire [3:0] o_m_led;

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

lab1_mux #(.INPUT_WIDTH(4)) u_mux (.i_x(o_m_led),.i_sel(i_rst),.o_f(w_led));

assign o_led='{default:w_led};

genvar i;

generate for (i=0;i<=3;i++) begin
lab2_led_n# ( .CLK_FREQUENCY(CLK_FREQUENCY),
    .BLINK_PERIOD (BLINK_PERIOD[i]),
    .OUT_WIDTH(1)) l0 (.i_clk(i_clk),.o_led(o_m_led[i]));
end
endgenerate

endmodule
