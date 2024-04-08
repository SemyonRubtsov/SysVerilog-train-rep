`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2024 07:52:19 PM
// Design Name: 
// Module Name: led_PWM
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




//module led_PWM
//#(
//    parameter CLK_FREQUENCY = 200000000, // Гц
//    parameter BLINK_PERIOD = 1 // секунды
//)
//(
//    input wire i_clk,
//    input wire i_rst, //!!!
//    output logic [3:0] o_led = '0
//);
//
////-- Constants
//    localparam COUNTER_PERIOD = int'(BLINK_PERIOD * CLK_FREQUENCY)/2;
//    localparam COUNTER_WIDTH = int'($ceil($clog2(COUNTER_PERIOD +1)));
//    localparam PWM_PERIOD=int'(COUNTER_PERIOD/100/2);
//    
////-- Counter
//    logic on_led=0;
//    int PWM=0;
//    int pwm_value=0;
//    reg [COUNTER_WIDTH -1 : 0] counter_value = '0;
//    reg [PWM_PERIOD -1 : 0] PWM_counter= '0;
//    always_ff @(posedge i_clk) begin
//    
//    //on_led=!on_led;
//    
//    if (i_rst || counter_value == COUNTER_PERIOD-1)
//        begin
//            counter_value <= 0;
//            //PWM=PWM+10;
//        end
//        else
//            counter_value <= counter_value +1;
//            
//        //PWM=(counter_value/5000)*100;
//        //PWM=int'((counter_value/COUNTER_PERIOD)*100);
//    if (PWM_counter==PWM_PERIOD)
//        begin
//            if ((counter_value < COUNTER_PERIOD/2) && PWM<100)
//                PWM=PWM+1;
//            if ((counter_value > COUNTER_PERIOD/2) && PWM>0)
//                PWM=PWM-1;
//            PWM_counter<=0;
//        end
//    else
//        PWM_counter<=PWM_counter+1;
//        
//        
//        
//    if (pwm_value >= 100)
//        begin
//            pwm_value=0;
//        end
//    else
//        pwm_value=pwm_value+1;
//    
//    
//    
//    if (pwm_value<PWM)
//        on_led=1;
//    else
//        on_led=0;
//    
//    o_led[3:1] <= {$size(o_led[3:1]){on_led}};
//    o_led[0] <= !on_led;
//end
//
//endmodule

module led_PWM
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
    localparam PWM_PERIOD=int'(COUNTER_PERIOD/100/2);
    localparam PWM_WIDTH = int'($ceil($clog2(PWM_PERIOD +1)));
    
    
//-- Counter
    logic on_led=0;
    reg [7 : 0] PWM='0;
    reg [7 : 0] pwm_value='0;
    reg [COUNTER_WIDTH -1 : 0] counter_value = '0;
    reg [PWM_WIDTH -1 : 0] PWM_counter= '0;
    always_ff @(posedge i_clk) begin
    
    //on_led=!on_led;
    
    if (i_rst || counter_value == COUNTER_PERIOD-1)
        begin
            counter_value <= 0;
            //PWM=PWM+10;
        end
        else
            counter_value <= counter_value +1;
            
        if (PWM_counter==PWM_PERIOD)
        begin
            if ((counter_value < COUNTER_PERIOD/2) && PWM<100)
                PWM=PWM+1;
            if ((counter_value > COUNTER_PERIOD/2) && PWM>0)
                PWM=PWM-1;
            PWM_counter<=0;
        end
        else
            PWM_counter<=PWM_counter+1;
        
        
        if (pwm_value > 100)
        begin
            pwm_value=0;
        end
        else
            on_led=!on_led;
        pwm_value=pwm_value+1;
            
        //on_led=pwm_value;

        //if ((counter_value < COUNTER_PERIOD/2) && PWM<100)
        //PWM=int'((counter_value/COUNTER_PERIOD)*100);
        //    
        //if ((counter_value > COUNTER_PERIOD/2) && PWM>0)
        //    PWM-=1;
 
        //else
        //    on_led <= 1;
        
        //o_led[3:1]<=on_led * 3'b111;
        o_led[3:1]<=on_led ? '1 : '0;
        //o_led[3:1] <= {$size(o_led[3:1]){on_led}};
        o_led[0] <= !on_led;
    end

endmodule
