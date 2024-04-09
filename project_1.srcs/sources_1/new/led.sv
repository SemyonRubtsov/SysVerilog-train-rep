`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2024 10:05:48 PM
// Design Name: 
// Module Name: led
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
