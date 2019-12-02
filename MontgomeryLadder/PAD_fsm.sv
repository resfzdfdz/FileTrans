/*******************************************************************************
  Copyright 2019 Xi'an Jiaotong University

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*******************************************************************************/

module PAD_fsm
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16,
	parameter DATA_LEN				= 256
)
(
	input logic 				clk,
	input logic 				rst,
	input logic 				start,
	input logic [DATA_LEN-1:0]	k,
	input logic [DATA_LEN-1:0] 	x1,
	input logic [DATA_LEN-1:0] 	y1,
	output logic [BIT_LEN-1:0] 	x3[NUM_ELEMENTS],
	output logic [BIT_LEN-1:0] 	z31[NUM_ELEMENTS],
	output logic [BIT_LEN-1:0] 	y3[NUM_ELEMENTS],
	output logic [BIT_LEN-1:0] 	z32[NUM_ELEMENTS],
	output logic 				finish
);

// Constant Definitions 
localparam B	= 272'h000028e9fa9e9d9f5e344d5a9e4bcf6509a7f39789f515ab8f92ddbcbd414d940e93;
localparam P4B 	= 272'h00035c5815818982872eca9586d0c26bd96031a1d827a951c1b8890d0afac9afc5b0;
localparam A	= 272'h0000fffffffeffffffffffffffffffffffffffffffff00000000fffffffffffffffc;
localparam B2	= 272'h000051d3f53d3b3ebc689ab53c979eca134fe72f13ea2b571f25bb797a829b281d26;
//localparam P2	= 256'hfffffffeffffffffffffffffffffffffffffffff00000000fffffffffffffffd;

localparam REG_NUM 					=	5;
localparam NUM_ADD					=	4;
localparam ZERO 					= 	17'h0;

logic [BIT_LEN-1:0] b[NUM_ELEMENTS];
logic [BIT_LEN-1:0] p4b[NUM_ELEMENTS];
logic [BIT_LEN-1:0] a[NUM_ELEMENTS];
logic [BIT_LEN-1:0] b2[NUM_ELEMENTS];

genvar i;
generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: const_b_p4b
		assign b[i] = 	{ {(BIT_LEN-WORD_LEN){1'b0}}, B[16*(i+1)-1 -: 16] 	};
		assign p4b[i] = { {(BIT_LEN-WORD_LEN){1'b0}}, P4B[16*(i+1)-1 -: 16] };
		assign a[i] = 	{ {(BIT_LEN-WORD_LEN){1'b0}}, A[16*(i+1)-1 -: 16] 	};
		assign b2[i] = 	{ {(BIT_LEN-WORD_LEN){1'b0}}, B2[16*(i+1)-1 -: 16] 	};
	end
endgenerate

// State Machine 
enum {IDLE, 
	// Pre-calculations
	PT1,
	// Pipeline Loop
	T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, 
	T12, T13, T14, T15, T16, T17, T18, T1,  
	// Final calculations
	// F1, F2, F3, F4, F5, F6, F7, F8, 
	// F9, F10, F11, F12, F13, F14,
	// Modular Inverse Loop
	// M1, M2, M3, M4, M5, M6, M7, M8
	// Finish 
	FINISH } state_now, state_next;

always_ff @(posedge clk)
begin
	if (rst)
		state_now <= IDLE;
	else
		state_now <= state_next;
end

// Counter for Pipeline Loop
logic [9:0] cnt;
always_ff @(posedge clk)
begin
	if (rst)
		cnt <= 10'b0;
	else
		if (state_now == T17)
			cnt <= cnt + 1'b1;
		else if (cnt == 10'd256)
			cnt <= 10'b0;
		else
			cnt <= cnt;
end

/* // Counter for Modular Inverse Loop
logic [9:0] cnt2;
always_ff @(posedge clk)
begin
	if (rst)
		cnt2 <= 10'b0;
	else
		if (state_next == F12)
			cnt2 <= cnt2 + 1'b1;
		else if (state_next == M1)
			cnt2 <= cnt2 + 1'b1;
		else
			cnt2 <= cnt2;
end */

always_comb begin
	case(state_now)
		IDLE:		state_next = start ? PT1 : IDLE;
		PT1:		state_next = T2;
		T1:			state_next = T2;
		T2:			state_next = T3;
		T3:			state_next = T4;
		T4:			state_next = T5;
		T5:			state_next = T6;
		T6:			state_next = T7;
		T7:			state_next = T8;
		T8:			state_next = T9;
		T9:			state_next = T10;
		T10:		state_next = T11;
		T11:		state_next = T12;
		T12:		state_next = T13;
		T13:		state_next = T14;
		T14:		state_next = T15;
		T15:		state_next = T16;
		T16:		state_next = T17;
		T17:		state_next = T18;
		T18:		state_next = (cnt == 10'd256) ? FINISH : T1;
/* 		F1:			state_next = F2;
		F2:			state_next = F3;
		F3:			state_next = F4;
		F4:			state_next = F5;
		F5:			state_next = F6;
		F6:			state_next = F7;
		F7:			state_next = F8;
		F8:			state_next = F9;
		F9:			state_next = F10;
		F10:		state_next = F11;
		F11:		state_next = F12;
		F12:		state_next = F13;
		F13:		state_next = F14;
		F14:		state_next = FINISH; */
/* 		M1:			state_next = M2;
		M2:			state_next = p2[DATA_LEN-1] ? M3 : 
								(cnt == 10'd256) ? M5 : M1;
		M3:			state_next = M4;
		M4:			state_next = (cnt == 10'd256) ? M5 : M1;
		M5:			state_next = M6;
		M6:			state_next = M7;
		M7:			state_next = M8;
		M8:			state_next = FINISH; */
		
		default:	state_next = IDLE;
	endcase
end

logic [DATA_LEN-1:0] k_reg;
logic [DATA_LEN-1:0] x1_reg;
logic [DATA_LEN-1:0] y1_reg;

logic [BIT_LEN-1:0] px[NUM_ELEMENTS];
logic [BIT_LEN-1:0] py[NUM_ELEMENTS];

generate
	for (i = 0; i < NUM_ELEMENTS-1; i++) begin: px_py
		assign px[i] = {1'b0, x1_reg[16*(i+1)-1 -: 16]};
		assign py[i] = {1'b0, y1_reg[16*(i+1)-1 -: 16]};
	end
	assign px[NUM_ELEMENTS-1] = ZERO;
	assign py[NUM_ELEMENTS-1] = ZERO;
endgenerate

always_ff @(posedge clk)
begin
	if (rst) 
		begin
			k_reg <= 256'h0;
			x1_reg <= 256'h0;
			y1_reg <= 256'h0;
		end
	else
		if (state_now == IDLE)
			begin
				k_reg <= k;
				x1_reg <= x1;
				y1_reg <= y1;
			end
		else if (state_now == T18)
			begin
				k_reg <= (k_reg << 1);
				x1_reg <= x1_reg;
				y1_reg <= y1_reg;
			end
		else
			begin
				k_reg <= k_reg;
				x1_reg <= x1_reg;
				y1_reg <= y1_reg;
			end
end

/* logic [DATA_LEN-1:0] p2;
always_ff @(posedge clk)
begin
	if (rst)
		p2 <= P2;
	else
		if (state_next == F12)
			p2 <= (p2 << 1);
		else if (state_next == F14)
			p2 <= (p2 << 1);
		else if (state_next == M2)
			p2 <= (p2 << 1);
		else
			p2 <= p2;
end */

// Data Path :
// modmul: 2 stage pipeline
// modadd: combinational
// modsub: combinational

logic [BIT_LEN-1:0] A_mul[NUM_ELEMENTS];
logic [BIT_LEN-1:0] B_mul[NUM_ELEMENTS];
logic [BIT_LEN-1:0] C_mul[NUM_ELEMENTS];

logic [BIT_LEN-1:0] A_add[NUM_ELEMENTS][NUM_ADD];
logic [BIT_LEN-1:0] SUM[NUM_ELEMENTS];

logic [BIT_LEN-1:0] A_sub[NUM_ELEMENTS];
logic [BIT_LEN-1:0] B_sub[NUM_ELEMENTS];
logic [BIT_LEN-1:0] SUB[NUM_ELEMENTS];

modmul #(
	.NUM_ELEMENTS		(	NUM_ELEMENTS	),
	.BIT_LEN			(	BIT_LEN			),
	.WORD_LEN			(	WORD_LEN		)
	) modmul	(
	.clk				(		clk			),
	.rst				(		rst			),
	.A					(		A_mul		),
	.B					(		B_mul		),
	.C					(		C_mul		)
);

modadd #(
	.NUM_ELEMENTS		(	NUM_ELEMENTS	),
	.BIT_LEN			(	BIT_LEN			),
	.WORD_LEN			(	WORD_LEN		),
	.NUM_ADD			(	NUM_ADD			)
	) modadd	(
	.A					(		A_add		),
	.SUM				(		SUM			)
);

modsub #(
	.NUM_ELEMENTS		(	NUM_ELEMENTS	),
	.BIT_LEN			(	BIT_LEN			),
	.WORD_LEN			(	WORD_LEN		)
	) modsub	(
	.A					(		A_sub		),
	.B					(		B_sub		),
	.SUB				(		SUB			)
);

//  Data path inputs 
logic [BIT_LEN-1:0] Lx[NUM_ELEMENTS];
logic [BIT_LEN-1:0] Lz[NUM_ELEMENTS];
logic [BIT_LEN-1:0] Hx[NUM_ELEMENTS];
logic [BIT_LEN-1:0] Hz[NUM_ELEMENTS];

logic [BIT_LEN-1:0] PDx[NUM_ELEMENTS];
logic [BIT_LEN-1:0] PDz[NUM_ELEMENTS];

logic [BIT_LEN-1:0] temp_PDx[NUM_ELEMENTS];
logic [BIT_LEN-1:0] temp_PDz[NUM_ELEMENTS];

logic [BIT_LEN-1:0] Reg_File[REG_NUM][NUM_ELEMENTS];

//int j;

always_ff @(posedge clk)
begin
	if (rst)
		for (int j = 0; j < NUM_ELEMENTS; j++) begin
			temp_PDx[j] <= ZERO;
			temp_PDz[j] <= ZERO;
		end
	else
		if (state_now == T11)
			for (int j = 0; j < NUM_ELEMENTS; j++) begin
				temp_PDx[j] <= Reg_File[1][j];
				temp_PDz[j] <= Reg_File[0][j];
			end
end

always_ff @(posedge clk)
begin
	if (rst)
		for (int j = 0; j < NUM_ELEMENTS; j++) begin
			Lx[j] <= ZERO;
			Lz[j] <= ZERO;
			Hx[j] <= ZERO;
			Hz[j] <= ZERO;
		end
	else
		if (state_now == T18)
			if (k_reg[DATA_LEN-1])
				for (int j = 0; j < NUM_ELEMENTS; j++) begin
					Lx[j] <= SUM[j];
					Lz[j] <= C_mul[j];
					Hx[j] <= temp_PDx[j];
					Hz[j] <= temp_PDz[j];
				end
			else
				for (int j = 0; j < NUM_ELEMENTS; j++) begin
					Lx[j] <= temp_PDx[j];
					Lz[j] <= temp_PDz[j];
					Hx[j] <= SUM[j];
					Hz[j] <= C_mul[j];
				end
		else if (state_now == IDLE)
			for (int j = 0; j < NUM_ELEMENTS; j++) begin
				if (j == 0) 
					begin
						Lx[j] = 17'b1;
						Lz[j] = ZERO;
						Hx[j] = px[j];
						Hz[j] = 17'b1;
					end
				else 
					begin
						Lx[j] = ZERO;
						Lz[j] = ZERO;
						Hx[j] = px[j];
						Hz[j] = ZERO;
					end
			end
		else
			for (int j = 0; j < NUM_ELEMENTS; j++) begin
				Lx[j] <= Lx[j];
				Lz[j] <= Lz[j];
				Hx[j] <= Hx[j];
				Hz[j] <= Hz[j];
			end
end

generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: PD_select
		assign PDx[i] = k_reg[DATA_LEN-1] ? Hx[i] : Lx[i];
		assign PDz[i] = k_reg[DATA_LEN-1] ? Hz[i] : Lz[i];
	end
endgenerate

always_comb 
begin
	case(state_now) 
		IDLE:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		PT1:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= PDz[j];
							B_mul[j] <= PDz[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
/* 		PT2:		begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= b[j];
							B_mul[j] <= PDz[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end */
		T1:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= PDz[j];
							B_mul[j] <= PDz[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T2:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= b[j];
							B_mul[j] <= PDz[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T3:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= PDx[j];
							B_mul[j] <= PDx[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[0][j];
							A_add[j][1] <= Reg_File[0][j];
							A_add[j][2] <= Reg_File[0][j];
							A_add[j][3] <= ZERO;
						end
					end
		T4:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[0][j];
							B_mul[j] <= Reg_File[1][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= PDz[j];
							A_add[j][1] <= PDz[j];
							A_add[j][2] <= PDz[j];
							A_add[j][3] <= PDz[j];
						end
					end
		T5:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Lz[j];
							B_mul[j] <= Hz[j];
							A_sub[j] <= Reg_File[2][j];
							B_sub[j] <= Reg_File[3][j];
							A_add[j][0] <= Reg_File[2][j];
							A_add[j][1] <= Reg_File[3][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T6:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= PDx[j];
							B_mul[j] <= Reg_File[3][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= PDx[j];
							A_add[j][1] <= PDx[j];
							A_add[j][2] <= PDx[j];
							A_add[j][3] <= PDx[j];
						end
					end
		T7:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[2][j];
							B_mul[j] <= Reg_File[0][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T8:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[4][j];
							B_mul[j] <= Reg_File[4][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[1][j];
							A_add[j][1] <= Reg_File[0][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T9:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[3][j];
							B_mul[j] <= Reg_File[2][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[0][j];
							A_add[j][1] <= Reg_File[0][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T10:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Lx[j];
							B_mul[j] <= Hz[j];
							A_sub[j] <= Reg_File[0][j];
							B_sub[j] <= Reg_File[4][j];
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T11:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Hx[j];
							B_mul[j] <= Lz[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T12:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Hx[j];
							B_mul[j] <= Lx[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T13:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= p4b[j];
							B_mul[j] <= Reg_File[2][j];
							A_sub[j] <= Reg_File[0][j];
							B_sub[j] <= Reg_File[1][j];
							A_add[j][0] <= Reg_File[0][j];
							A_add[j][1] <= Reg_File[1][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T14:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[2][j];
							B_mul[j] <= Reg_File[2][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[3][j];
							A_add[j][1] <= Reg_File[3][j];
							A_add[j][2] <= Reg_File[3][j];
							A_add[j][3] <= ZERO;
						end
					end
		T15:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[0][j];
							B_mul[j] <= Reg_File[1][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[3][j];
							A_add[j][1] <= Reg_File[4][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T16:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[3][j];
							B_mul[j] <= Reg_File[3][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T17:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= px[j];
							B_mul[j] <= Reg_File[0][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		T18:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[2][j];
							A_add[j][1] <= Reg_File[1][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
/*  		F1:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F2:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= px[j];
							B_mul[j] <= Lz[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F3:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= px[j];
							B_mul[j] <= Lx[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F4:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= a[j];
							B_mul[j] <= Lz[j];
							A_sub[j] <= Reg_File[0][j];
							B_sub[j] <= Lx[j];
							A_add[j][0] <= Reg_File[0][j];
							A_add[j][1] <= Lx[j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F5:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Lz[j];
							B_mul[j] <= Lz[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F6:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= py[j];
							B_mul[j] <= Hz[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[1][j];
							A_add[j][1] <= Reg_File[0][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F7:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[0][j];
							B_mul[j] <= b2[j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F8:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[2][j];
							B_mul[j] <= Reg_File[1][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[0][j];
							A_add[j][1] <= Reg_File[0][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F9:			begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Hx[j];
							B_mul[j] <= Reg_File[1][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F10:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[0][j];
							B_mul[j] <= Reg_File[2][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[4][j];
							A_add[j][1] <= Reg_File[3][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F11:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Hz[j];
							B_mul[j] <= Reg_File[4][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F12:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F13:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= Reg_File[2][j];
							A_add[j][1] <= Reg_File[3][j];
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		F14:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end  */
/* 		M1:			begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[1][j];
							B_mul[j] <= Reg_File[1][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		M2:			begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[2][j];
							B_mul[j] <= Reg_File[2][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		M3:			begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[0][j];
							B_mul[j] <= Reg_File[1][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		M4:			begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Lz[j];
							B_mul[j] <= Reg_File[2][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		M5:			begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Reg_File[1][j];
							B_mul[j] <= Reg_File[4][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		M6:			begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= Lx[j];
							B_mul[j] <= Reg_File[4][j];
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		M7:			begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		M8:			begin
						for (j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end */
		FINISH:		begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
		default:	begin
						for (int j = 0; j < NUM_ELEMENTS; j++) begin
							A_mul[j] <= ZERO;
							B_mul[j] <= ZERO;
							A_sub[j] <= ZERO;
							B_sub[j] <= ZERO;
							A_add[j][0] <= ZERO;
							A_add[j][1] <= ZERO;
							A_add[j][2] <= ZERO;
							A_add[j][3] <= ZERO;
						end
					end
	endcase
end

//  Register 
always_ff @(posedge clk)
begin
	if (rst)
		for (int j = 0; j < REG_NUM; j++) begin
			for (int k = 0; k < NUM_ELEMENTS; k++) begin
				Reg_File[j][k] <= ZERO;
			end
		end
	else
		case(state_next)
			IDLE:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			PT1:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
/* 			PT2:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end */
			T1:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= C_mul[j];
								Reg_File[2][j] <= SUM[j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			T2:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= C_mul[j];
								Reg_File[2][j] <= SUM[j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			T3:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			T4:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= C_mul[j];
								Reg_File[2][j] <= SUM[j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			T5:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= Reg_File[1][j];
								Reg_File[2][j] <= C_mul[j];
								Reg_File[3][j] <= Reg_File[2][j];
								Reg_File[4][j] <= SUM[j];
							end
						end
			T6:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[4][j];
								Reg_File[2][j] <= SUM[j];
								Reg_File[3][j] <= SUB[j];
								Reg_File[4][j] <= ZERO;
							end
						end
			T7:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= C_mul[j];
								Reg_File[2][j] <= SUM[j];
								Reg_File[3][j] <= Reg_File[1][j];
								Reg_File[4][j] <= Reg_File[2][j];
							end
						end
			T8:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= C_mul[j];
								Reg_File[2][j] <= Reg_File[1][j];
								Reg_File[3][j] <= Reg_File[3][j];
								Reg_File[4][j] <= Reg_File[4][j];
							end
						end
			T9:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[2][j];
								Reg_File[2][j] <= SUM[j];
								Reg_File[3][j] <= Reg_File[3][j];
								Reg_File[4][j] <= ZERO;
							end
						end
			T10:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[1][j];
								Reg_File[2][j] <= Reg_File[2][j];
								Reg_File[3][j] <= Reg_File[3][j];
								Reg_File[4][j] <= SUM[j];
							end
						end
			T11:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= SUB[j];
								Reg_File[2][j] <= Reg_File[1][j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			T12:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[2][j];
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			T13:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= C_mul[j];
								Reg_File[2][j] <= Reg_File[1][j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			T14:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= SUM[j];
								Reg_File[2][j] <= SUB[j];
								Reg_File[3][j] <= Reg_File[2][j];
								Reg_File[4][j] <= ZERO;
							end
						end
			T15:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[1][j];
								Reg_File[2][j] <= Reg_File[2][j];
								Reg_File[3][j] <= Reg_File[0][j];
								Reg_File[4][j] <= SUM[j];
							end
						end
			T16:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[0][j];
								Reg_File[2][j] <= Reg_File[1][j];
								Reg_File[3][j] <= SUM[j];
								Reg_File[4][j] <= ZERO;
							end
						end
			T17:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= C_mul[j];
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			T18:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= Reg_File[1][j];
								Reg_File[2][j] <= C_mul[j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
/* 			F1:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= C_mul[j];
								Reg_File[2][j] <= SUM[j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			F2:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			F3:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= ZERO;
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			F4:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			F5:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[1][j];
								Reg_File[1][j] <= SUM[j];
								Reg_File[2][j] <= SUB[j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			F6:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[0][j];
								Reg_File[2][j] <= Reg_File[1][j];
								Reg_File[3][j] <= Reg_File[2][j];
								Reg_File[4][j] <= ZERO;
							end
						end
			F7:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= SUM[j];
								Reg_File[2][j] <= Reg_File[2][j];
								Reg_File[3][j] <= Reg_File[3][j];
								Reg_File[4][j] <= ZERO;
							end
						end
			F8:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[1][j];
								Reg_File[2][j] <= Reg_File[2][j];
								Reg_File[3][j] <= Reg_File[3][j];
								Reg_File[4][j] <= Reg_File[0][j];
							end
						end
			F9:			begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= SUM[j];
								Reg_File[1][j] <= Reg_File[3][j];
								Reg_File[2][j] <= Reg_File[4][j];
								Reg_File[3][j] <= C_mul[j];
								Reg_File[4][j] <= ZERO;
							end
						end
			F10:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= Reg_File[1][j];
								Reg_File[2][j] <= Reg_File[2][j];
								Reg_File[3][j] <= Reg_File[3][j];
								Reg_File[4][j] <= C_mul[j];
							end
						end
			F11:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[2][j];
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= SUM[j];
							end
						end
			F12:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= C_mul[j];
								Reg_File[1][j] <= Reg_File[4][j];
								Reg_File[2][j] <= Reg_File[0][j];
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= ZERO;
							end
						end
			F13:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= C_mul[j];
								Reg_File[3][j] <= Reg_File[2][j];
								Reg_File[4][j] <= ZERO;
							end
						end
			F14:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= ZERO;
								Reg_File[2][j] <= ZERO;
								Reg_File[3][j] <= ZERO;
								Reg_File[4][j] <= SUM[j];
							end
						end */
			FINISH:		begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= Reg_File[1][j];
								Reg_File[2][j] <= Reg_File[2][j];
								Reg_File[3][j] <= Reg_File[3][j];
								Reg_File[4][j] <= Reg_File[4][j];
							end
						end
			default:	begin
							for (int j = 0; j < NUM_ELEMENTS; j++) begin
								Reg_File[0][j] <= Reg_File[0][j];
								Reg_File[1][j] <= Reg_File[1][j];
								Reg_File[2][j] <= Reg_File[2][j];
								Reg_File[3][j] <= Reg_File[3][j];
								Reg_File[4][j] <= Reg_File[4][j];
							end
						end
	endcase
end

always_comb begin
	if (state_now == FINISH)
		for (int j = 0; j < NUM_ELEMENTS; j++) begin
			x3[j] 	= 	Lx[j];
			z31[j] 	= 	Lz[j];
			y3[j]	= 	Reg_File[4][j];
			z32[j]	= 	Reg_File[0][j];
		end
	else
		for (int j = 0; j < NUM_ELEMENTS; j++) begin
			x3[j] 	= 	ZERO;
			z31[j] 	= 	ZERO;
			y3[j]	= 	ZERO;
			z32[j]	= 	ZERO;
		end
end

assign finish = (state_now == FINISH);

endmodule