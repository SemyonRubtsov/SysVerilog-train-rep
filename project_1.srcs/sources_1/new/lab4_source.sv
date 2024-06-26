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

//interface if_axis #(parameter int N = 1) ();
//	localparam W = 8 * N; // TDATA bit width (N - number of bytes)
	
//	logic         tready;
//	logic         tvalid;
//	logic         tlast ;
//	logic [W-1:0] tdata ;
	
//	modport m (input tready, output tvalid, tlast, tdata);
//	//modport s (output tready, input tvalid, tlast, tdata);
	
//endinterface : if_axis

module lab4_source
#(
    parameter G_BYT = 1,
    parameter P_LEN_MAX = 63,
    parameter CRC_WAIT=1
)
(
    input reg [5:0] i_p_len,
    input logic i_clk,                                                                 
    input logic i_rst,                                                              
    
    if_axis.m m_axis
     
);
    
    initial begin
        m_axis.tvalid='0;
        m_axis.tlast='0;
        m_axis.tdata='0;
    end;
    
    localparam PACKET_WIDTH=int'($ceil($clog2(P_LEN_MAX+1)));
    
    reg [PACKET_WIDTH -1 :0] cnt;
    
    logic [G_BYT*8-1:0] o_crc_res_dat;
    logic [G_BYT*8-1:0] i_crc_wrd_dat='0;
    logic m_wrd_vld='0;
    logic m_crc_rst='0;
    reg[5:0] o_p_len_sync;
    
    crc #(
        .POLY_WIDTH (8), // Size of The Polynomial Vector
		.WORD_WIDTH (8), // Size of The Input Words Vector
		.WORD_COUNT (0   ), // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5), // Polynomial Bit Vector
		.INIT_VALUE ('h01), // Initial Value
		.CRC_REF_IN ('0  ), // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
		.CRC_REFOUT ('0  ), // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
		.BYTES_RVRS ('0  ), // Input Word Byte Reverse
		.XOR_VECTOR ('0  ), // CRC Final Xor Vector
		.NUM_STAGES (1   )  // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3..NUM_STAGES(1) // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
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
    
    assign o_p_len_sync = (m_axis.tlast | i_rst) ? i_p_len : o_p_len_sync;
    
    enum logic [2:0] {S0 = 3'b00,
                     S1 = 3'b01,
                     S2 = 3'b10,
                     S3 = 3'b11} S;
    
    task make_valid;
    if (m_axis.tready & !m_axis.tvalid)
        m_axis.tvalid <= '1;
    endtask
    
    
    
    always_ff @(posedge i_clk) begin
        
        if (i_rst) begin
            S <= S0;
            cnt=0;
            m_crc_rst='1;
            m_axis.tvalid<='0;
            m_axis.tlast<='0;
            m_axis.tdata<='0;
        end
        else
            case(S)
                S0:begin
                    
                    if (m_axis.tready) begin
                        S <= S1;
                        m_axis.tvalid <= '0;
                        cnt<=0;   
                        m_crc_rst='1;
                        m_axis.tlast <= '0;
                     end   
                end
                S1:begin //send data
                    
                    if (m_axis.tready & !m_axis.tvalid) begin
                        m_axis.tvalid <= '1;
                        //m_wrd_vld<=1;
                    end
                    m_crc_rst='0;
                    //else m_wrd_vld<=0;
                    //m_axis.tvalid<=m_axis.tready ? '1 : '0;
                    //m_wrd_vld<=m_axis.tready ? '1 : '0;
                    
                    if (m_axis.tready & cnt<o_p_len_sync) begin
                        if (cnt==0) m_axis.tdata  <= 72;
                        else if (cnt==1) m_axis.tdata  <= o_p_len_sync;
                        else begin 
                            m_wrd_vld<=m_axis.tready ? '1 : '0;
                            m_axis.tdata  <= cnt-1;
                            i_crc_wrd_dat <= cnt-1;
                        end
                        cnt<=cnt+1;
                    end
                    
                    if (m_axis.tvalid & m_axis.tready & cnt==o_p_len_sync) begin
                        S <= S2;
                        m_axis.tvalid <= '0;
                        //m_axis.tdata  <= o_crc_res_dat;
                        m_wrd_vld<=0;
                        cnt<='0;
                    end
                end
                S2:begin
                    if (m_axis.tready & !m_axis.tvalid) begin
                        m_axis.tvalid <= '1;
                        m_axis.tlast <= '1;
                    end
                    //Send CRC
                    
                    m_axis.tdata  <= o_crc_res_dat;
                        
                    if (m_axis.tvalid & m_axis.tready) begin
                        S <= S0;
                        m_axis.tvalid <= '0;
                        cnt<='0;
                        
                    end
                end
                S3:begin
                    //m_crc_rst='1;
                    if (m_axis.tready & cnt<1)
                        cnt=cnt+1;
                    else
                        S<=S0;
                end
        endcase
        //axis_init;
        //send_pkt;
    end
    
endmodule