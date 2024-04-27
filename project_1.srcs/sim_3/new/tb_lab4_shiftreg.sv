`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 03:48:57 AM
// Design Name: 
// Module Name: tb_lab4_shiftreg
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


module tb_lab4_shiftreg(

    );
    
logic i_clk='1; byte i_data=0; int cnt=0;  logic i_reg_vld='0;

lab4_shiftreg u_shift(
    .i_data(i_data),
    .i_clk(i_clk),
    .i_reg_vld(i_reg_vld)
); 

always #(0.5) i_clk=~i_clk;

always @(posedge i_clk) begin

    //cnt<=cnt+1;

end

always #(i_clk) begin
    
    if (cnt<10) begin
        i_reg_vld<='1;
        cnt<=cnt+1;
        i_data<=cnt;
    end
    else begin
        i_reg_vld<='0;
        #1;
        i_reg_vld<='1;
        i_data<=240;
        #1;
        i_reg_vld<='0;
        cnt<=0;
    end
    
end

initial begin
    #1
    i_reg_vld<='0;
    #14;
    i_reg_vld<='1;
    #3;
    //i_reg_vld<='1;
    #10;
    i_reg_vld<='0;
    #10;
    i_reg_vld<='1;
end

endmodule
