`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 07:50:02 PM
// Design Name: 
// Module Name: lab4_source
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


module lab4_source
#(
parameter G_BYT = 1,
parameter P_LEN = 10
)
(
    input logic i_clk,                                                                 
    input logic i_rst,                                                              
    //input i_snd,
                                                                               
    output logic m_axis_tvalid,            // output wire m_axis_tvalid       
    input logic m_axis_tready,            // input wire m_axis_tready        
    output reg [7:0] m_axis_tdata,              // output wire [7 : 0] m_axis_tdata
    output logic m_axis_tlast              // output wire m_axis_tlast         
    );
    
    if_axis #(.N(G_BYT)) m_axis();
    reg [int'($ceil($clog2(P_LEN+1))):0] cnt;
    // send packet to AXIS FIFO
    
    enum logic [3:0] {S0 = 3'b001,
                     S1 = 3'b010,
                     S2 = 3'b011,
                     S3 = 3'b100,
                     S4 = 3'b101,
                     S5 = 3'b110,
                     S6 = 3'b111} S;
    
    task make_valid;
    if (m_axis_tready & !m_axis_tvalid)
        m_axis_tvalid <= '1;
    endtask
    
    always_ff @(posedge i_clk) begin
        
        //if i<P_LEN
        
        if (i_rst) begin
            S <= S0;
            cnt=0;
        end
        else
            case(S)
                S0:begin
                    if (m_axis_tready)
                        S <= S1;
                        m_axis_tvalid <= '0;
                end
                S1:begin
                    if (m_axis_tready & !m_axis_tvalid) m_axis_tvalid <= '1;
                        
                    m_axis.tdata  <= 72;
                    
                    if (m_axis_tvalid & m_axis_tready) begin
                        S <= S2;
                        m_axis_tvalid <= '0;
                        cnt<='0;
                    end
                end
                S2:begin
                if (m_axis_tready & !m_axis_tvalid) m_axis_tvalid <= '1;
                        
                    m_axis.tdata  <= P_LEN;
                    
                    if (m_axis_tvalid & m_axis_tready) begin
                        S <= S3;
                        m_axis_tvalid <= '0;
                        cnt<='0;
                    end
                end
                S3:begin
                    if (m_axis_tready & !m_axis_tvalid) m_axis_tvalid <= '1;
                    
                    if (cnt<P_LEN) begin
                        m_axis.tdata  <= cnt;
                        cnt<=cnt+1;
                    end
                    
                    if (m_axis_tvalid & m_axis_tready & cnt==P_LEN) begin
                        S <= S4;
                        m_axis_tvalid <= '0;
                        cnt<='0;
                    end
                end
                S4:begin
                    if (cnt<P_LEN)
                        cnt=cnt+1;
                    else
                        S<=S0;
                end
        endcase
        //axis_init;
        //send_pkt;
    end
    
endmodule
