`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/13/2024 05:35:35 PM
// Design Name: 
// Module Name: lab4_source_divided_FSM
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

module lab4_source_divided_FSM #(
    parameter G_BYT = 1,
    parameter P_LEN_MAX = 63,
    parameter CRC_WAIT=1,
	int G_NUM = 1 // number of traffic lights / sensors
) (
	input  wire              i_clk     , // clock
	input  wire              i_rst   , // reset, active-high
	input  wire  [5:0] i_p_len, // packet length
	//output logic [G_NUM-1:0] o_trfl_val = '0, // traffic lights control signals
	
	if_axis.m m_axis
	
);

reg[5:0] o_p_len_sync;

localparam C_CNT_WID=int'($ceil($clog2(P_LEN_MAX+1)));

//assign o_p_len_sync = (m_axis.tlast | i_rst) ? i_p_len : o_p_len_sync;

typedef enum {S0_READY,
              S1_SND_PKT,
              S2_SND_CRC
              } t_fsm_states;

t_fsm_states w_next_state, q_crnt_state = S0_READY;

//localparam C_CNT_WID = 4; // timeout counter bit width
logic [C_CNT_WID-1:0] q_timeout_cnt = '1;
wire [7:0] o_crc_res_dat;
logic m_wrd_vld='0;
logic m_crc_rst;

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
        .i_crc_wrd_dat(m_axis.tdata),
        .o_crc_wrd_rdy (),
        .o_crc_res_vld (),
        .o_crc_res_dat(o_crc_res_dat)
    );

// FSM next state decode
always_comb begin
	w_next_state = q_crnt_state;
	case (q_crnt_state)
	S0_READY: if (m_axis.tready) begin
               w_next_state = S1_SND_PKT;
               o_p_len_sync=i_p_len;
		end
	S1_SND_PKT: w_next_state = (m_axis.tvalid & m_axis.tready & q_timeout_cnt==o_p_len_sync+2) ? S2_SND_CRC : S1_SND_PKT;
	S2_SND_CRC: begin
	   w_next_state = (!m_axis.tvalid & m_axis.tready) ? S0_READY : S2_SND_CRC;
	   m_wrd_vld=0;
	end
	default : w_next_state = S0_READY;
endcase
end

// counter
always_ff @(posedge !i_clk) begin // remove inversion?
if (q_timeout_cnt < o_p_len_sync+2 & m_axis.tready)
			q_timeout_cnt <= q_timeout_cnt + 1;
			
if (q_crnt_state==S0_READY) q_timeout_cnt <= '0;

end

// FSM current state sync
	always_ff @(posedge i_clk) begin
		q_crnt_state <= (i_rst) ? S0_READY : w_next_state;
		
		//if (m_axis.tready & !m_axis.tvalid)
        //                m_axis.tvalid <= '1;
    end

// handle states
always_ff @(posedge i_clk) begin
       case(q_crnt_state)
       
       S0_READY:begin
           m_crc_rst<='1;
           //q_timeout_cnt <= '0;
           m_axis.tvalid <= '0;
           m_axis.tlast <= '0;
       end
       
	S1_SND_PKT:begin
	m_crc_rst='0;
	if (m_axis.tready & !m_axis.tvalid)
                       m_axis.tvalid <= '1;
       //m_axis.tvalid <= m_axis.tready;
       //else m_axis.tvalid <= '0; 
	
	if (q_timeout_cnt==1) m_axis.tdata  <= 72;
       else if (q_timeout_cnt==2) m_axis.tdata  <= o_p_len_sync-1;
       else begin 
           m_wrd_vld<=(m_axis.tready) ? '1 : '0;
           m_axis.tdata  <= q_timeout_cnt-2;
	end
	
	if (m_axis.tready & m_axis.tvalid & q_timeout_cnt==o_p_len_sync+2) begin
           //m_wrd_vld<=0;
           m_axis.tvalid<=0;
	end
	end
	
	S2_SND_CRC:begin
	    
	    //m_wrd_vld<=1;
	    m_axis.tvalid<=m_axis.tready;
	    m_wrd_vld<=0;
//           if (m_axis.tready) begin
           
//               m_axis.tvalid<=1;
               
//               if (!m_axis.tvalid) begin
//                   m_wrd_vld<=0;
//                   //m_axis.tvalid <= '1;
//                   m_axis.tlast <= '1;
//                   //q_timeout_cnt <= '0;
//               end
      //         
//           end
           //else
               //m_axis.tvalid<=1;
        
        if (m_axis.tready) begin
            m_axis.tdata  <= o_crc_res_dat;
            m_axis.tlast <= '1;
        end
        else m_wrd_vld<=0;
        
    end
    endcase;
end
endmodule
