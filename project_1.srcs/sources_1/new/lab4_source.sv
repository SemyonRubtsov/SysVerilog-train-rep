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
parameter P_LEN = 10,
parameter CRC_WAIT=10
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
    
    localparam PACKET_WIDTH=int'($ceil($clog2(P_LEN+1)));
    
    if_axis #(.N(G_BYT)) m_axis();
    reg [PACKET_WIDTH -1 :0] cnt;
    // send packet to AXIS FIFO
    
    logic [G_BYT*8-1:0] o_crc_res_dat='0;
    logic [G_BYT*8-1:0] i_crc_wrd_dat='0;
    logic m_wrd_vld='0;
    logic m_crc_rst='0;
    
    crc #(
        .POLY_WIDTH (8), // Size of The Polynomial Vector
		.WORD_WIDTH (8), // Size of The Input Words Vector
		.WORD_COUNT (0   ), // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5), // Polynomial Bit Vector
		.INIT_VALUE ('1  ), // Initial Value
		.CRC_REF_IN ('0  ), // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
		.CRC_REFOUT ('0  ), // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
		.BYTES_RVRS ('0  ), // Input Word Byte Reverse
		.XOR_VECTOR ('0  ), // CRC Final Xor Vector
		.NUM_STAGES (2   )  // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3..NUM_STAGES(1) // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
    ) u_crc (
        .i_crc_a_clk_p(i_clk),
        .i_crc_s_rst_p(m_crc_rst),
        .i_crc_ini_vld('0),
        .i_crc_wrd_vld(m_wrd_vld),
        .i_crc_ini_dat('0),
        .i_crc_wrd_dat(i_crc_wrd_dat),
        .o_crc_wrd_rdy (),
        .o_crc_res_vld (),
        .o_crc_res_dat(o_crc_res_dat)
    );
    
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
            m_crc_rst='0;
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
                    m_crc_rst='1;
                    
                    if (m_axis_tvalid & m_axis_tready) begin
                        S <= S2;
                        m_axis_tvalid <= '0;
                        cnt<='0;
                        m_crc_rst='0;
                    end
                end
                S2:begin
                if (m_axis_tready & !m_axis_tvalid) m_axis_tvalid <= '1;
                        
                    m_axis.tdata  <= P_LEN;
                    
                    
                    if (m_axis_tvalid & m_axis_tready) begin
                        S <= S3;
                        m_axis_tvalid <= '0;
                        cnt<='0;
                        m_wrd_vld<=1;
                    end
                end
                S3:begin //send data
                    if (m_axis_tready & !m_axis_tvalid) m_axis_tvalid <= '1;
                    
                    if (cnt<P_LEN) begin
                        m_axis.tdata  <= cnt;
                        i_crc_wrd_dat <= cnt;
                        cnt<=cnt+1;
                    end
                    
                    if (m_axis_tvalid & m_axis_tready & cnt==P_LEN) begin
                        S <= S4;
                        m_axis_tvalid <= '0;
                        cnt<='0;
                    end
                end
                S4:begin
                    if (cnt<CRC_WAIT)
                        cnt=cnt+1;
                    else
                        S<=S5;
                        m_wrd_vld<=0;
                end
                S5:begin
                    if (m_axis_tready & !m_axis_tvalid) m_axis_tvalid <= '1;
                    
                    //Send CRC
                    
                    m_axis.tdata  <= o_crc_res_dat;
                        
                    if (m_axis_tvalid & m_axis_tready) begin
                        S <= S6;
                        m_axis_tvalid <= '0;
                        m_axis_tlast <= '0;
                        cnt<='0;
                        
                    end
                end
                S6:begin
                    //m_crc_rst='1;
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
