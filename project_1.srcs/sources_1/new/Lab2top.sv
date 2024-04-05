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

module led
#(
    parameter CLK_FREQUENCY = 200000000, // Гц
    parameter BLINK_PERIOD = 1 // секунды
)
(
    input wire i_clk,
    input wire i_rst, //!!!
    output logic [3:0] o_led = '0
);

//-- Constants
    localparam COUNTER_PERIOD = int'(BLINK_PERIOD * CLK_FREQUENCY);
    localparam COUNTER_WIDTH = int'($ceil($clog2(COUNTER_PERIOD +1)));
    
//-- Counter
    logic on_led=0;
    reg [COUNTER_WIDTH -1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin
        if (i_rst || counter_value == COUNTER_PERIOD-1)
            counter_value <= 0;
        else
            counter_value <= counter_value +1;
        
        if (counter_value < COUNTER_PERIOD/2)
            on_led <= 0;
        else
            on_led <= 1;
        //o_led[3:1]<=on_led * 3'b111;
        //o_led[3:1]<=on_led ? '1 : '0;
        o_led[3:1] <= {$size(o_led[3:1]){on_led}};
        o_led[0] <= !on_led;
    end

endmodule

module Lab2top
(
    input wire clk_in1_p,
    input wire clk_in1_n,
    input wire i_rst,
    output logic [3:0] o_led
    //output wire i_clk
);

wire [2:0] i_clk;

clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(i_clk[0]),     // output clk_out1
    // Status and control signals
    .reset(i_rst), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1_p(clk_in1_p),    // input clk_in1_p
    .clk_in1_n(clk_in1_n)
    );    // input clk_in1_n

led l0 (.i_clk(i_clk[0]),.i_rst(i_rst),.o_led(o_led));

endmodule

