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

module moddiv
#(
    parameter DATA_LEN		=	256,
	parameter CONT_LEN		=	30
)
(
	input logic 				clk,
	input logic 				rst,
	input logic [DATA_LEN-1:0] 	u_in,
	input logic [DATA_LEN-1:0] 	v_in,
	input logic [DATA_LEN+4:0] 	m_in,
	input logic [DATA_LEN+4:0] 	n_in,
	input logic [0:CONT_LEN-1]	ctrl,
	output logic [DATA_LEN-1:0] U,
	output logic [DATA_LEN-1:0] V,
	output logic [DATA_LEN+4:0] M,
	output logic [DATA_LEN+4:0] N,
	output logic				U_eq1,
	output logic				bor2,
	output logic [1:0]			n1,
	output logic [1:0]			n2
);

localparam P = 256'hFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF;

//  U, V Data Path
logic [DATA_LEN-1:0] A_sub1;
logic [DATA_LEN-1:0] B_sub1;
logic [DATA_LEN-1:0] A_sub2;
logic [DATA_LEN-1:0] B_sub2;

logic [DATA_LEN-1:0] U_V;
logic [DATA_LEN-1:0] V_U;

logic [DATA_LEN-1:0] U_V_abs;
logic [DATA_LEN-1:0] UV_abs;
logic [DATA_LEN-1:0] U_V_shifted;
logic [DATA_LEN-1:0] UV_shifted;

/* logic [1:0] n1;
logic [1:0] n2;
logic bor2; */

logic [2:0] U_V_2_0;
logic [2:0] UV_2_0;

logic [1:0] shift_n1;
logic [1:0] shift_n2;

assign A_sub1 = U;
assign B_sub1 = { (DATA_LEN){ctrl[0]} } & V;
assign A_sub2 = V;
assign B_sub2 = U;

assign 		  U_V  = A_sub1 - B_sub1;
assign {bor2, V_U} = {1'b0, A_sub2} - {1'b0, B_sub2};

assign U_V_abs = (bor2 | ctrl[1]) ? U_V : V_U;
assign UV_abs = (bor2 | ctrl[1])  ? V 	: U;

assign U_V_2_0 = (bor2 | ctrl[1]) ? U_V[2:0] : V_U[2:0];
assign UV_2_0  = (bor2 | ctrl[1]) ? V[2:0] 	 : U[2:0];

assign n1 = (U_V_2_0 == 3'b000) 	? 2'b11 : 
			(U_V_2_0[1:0] == 2'b00) ? 2'b10 :
			(U_V_2_0[0] == 1'b0) 	? 2'b01 : 2'b00;

assign n2 = (UV_2_0 == 3'b000) 		? 2'b11 : 
			(UV_2_0[1:0] == 2'b00) 	? 2'b10 :
			(UV_2_0[0] == 1'b0) 	? 2'b01 : 2'b00;

assign shift_n1 = n1 & {ctrl[2], ctrl[3]};
assign shift_n2 = n2 & {ctrl[5], ctrl[6]};

always_comb begin
	case(shift_n1)
		2'b00:			U_V_shifted = U_V_abs;
		2'b01:			U_V_shifted = U_V_abs >> 1;
		2'b10:			U_V_shifted = U_V_abs >> 2;
		2'b11:			U_V_shifted = U_V_abs >> 3;
	endcase
end

always_comb begin
	case(shift_n2)
		2'b00:			UV_shifted = UV_abs;
		2'b01:			UV_shifted = UV_abs >> 1;
		2'b10:			UV_shifted = UV_abs >> 2;
		2'b11:			UV_shifted = UV_abs >> 3;
	endcase
end		

always_ff @(posedge clk)
begin
	if (rst)
		U <= 256'b0;
	else
		U <= ctrl[4] ? U_V_shifted : u_in;
end

always_ff @(posedge clk)
begin
	if (rst)
		V <= 256'b0;
	else
		V <= ctrl[4] ? UV_shifted : v_in;
end

logic Q_bor;
logic [1:0] Q_n1;
logic [1:0] Q_n2;

always_ff @(posedge clk)
begin
	if (rst)
		begin
			Q_bor 	<= 	1'b0;
			Q_n1	<=	2'b0;
			Q_n2	<=	2'b0;
		end
	else
		begin
			Q_bor 	<= 	bor2;
			Q_n1	<=	n1;
			Q_n2	<=	n2;
		end
end

//  M, N Data Path
logic [2:0] M_N_2_0;
logic [2:0] MN_2_0;

logic M_N_symbol;
logic MN_symbol;

logic [DATA_LEN+4:0] A_adderm;
logic [DATA_LEN+4:0] B_adderm;
logic [DATA_LEN+4:0] C_adderm;
logic [DATA_LEN+4:0] xp_xpm;

logic [DATA_LEN+4:0] A_addern;
logic [DATA_LEN+4:0] B_addern;

logic [DATA_LEN+4:0] xpm;
logic [DATA_LEN+4:0] xpn;

logic [DATA_LEN+4:0] M_sum;
logic [DATA_LEN+4:0] N_sum;

logic [DATA_LEN+4:0] M_shifted;
logic [DATA_LEN+4:0] N_shifted;

assign M_N_2_0 = Q_bor ? (M[2:0] - N[2:0]) : (N[2:0] - M[2:0]);
assign MN_2_0  = Q_bor ? N[2:0] : M[2:0];

assign M_N_symbol = Q_bor ? M[DATA_LEN+4] : N[DATA_LEN+4];
assign MN_symbol  = Q_bor ? N[DATA_LEN+4] : M[DATA_LEN+4];

// Adder M
assign xp_xpm   = ctrl[13] ? {5'h0, P} : xpm;
assign A_adderm = ( {(DATA_LEN+5){ctrl[7]}}  & M) 	   | ( ~( {(DATA_LEN+5){ctrl[8]}}  | M) );
assign B_adderm = ( {(DATA_LEN+5){ctrl[9]}}  & xp_xpm) | ( ~( {(DATA_LEN+5){ctrl[10]}} | xp_xpm) );
assign C_adderm = ( {(DATA_LEN+5){ctrl[11]}} & N) 	   | ( ~( {(DATA_LEN+5){ctrl[12]}} | N) );
assign M_sum	= A_adderm + B_adderm + C_adderm + ctrl[14];

// Adder N
assign A_addern = ( {(DATA_LEN+5){ctrl[17]}} & N) | ( {(DATA_LEN+5){ctrl[18]}} & M);
assign B_addern = ( {(DATA_LEN+5){ctrl[19]}} & N) | ( ~( {(DATA_LEN+5){ctrl[20]}} | N) ) | ({(DATA_LEN+4){ctrl[21]}} & xpn);
assign N_sum	= A_addern + B_addern + ctrl[22];

always_comb begin
	case({ctrl[15], ctrl[16]})
		2'b00:		M_shifted 	=	M_sum;
		2'b01:		M_shifted 	=	{ {(1){M_sum[DATA_LEN+4]}}, M_sum[DATA_LEN+4:1]};
		2'b10:		M_shifted 	=	{ {(2){M_sum[DATA_LEN+4]}}, M_sum[DATA_LEN+4:2]};
		2'b11:		M_shifted 	=	{ {(3){M_sum[DATA_LEN+4]}}, M_sum[DATA_LEN+4:3]};
	endcase
end

always_comb begin
	case({ctrl[23], ctrl[24]})
		2'b00:		N_shifted 	=	N_sum;
		2'b01:		N_shifted 	=	{ {(1){N_sum[DATA_LEN+4]}}, N_sum[DATA_LEN+4:1]};
		2'b10:		N_shifted 	=	{ {(2){N_sum[DATA_LEN+4]}}, N_sum[DATA_LEN+4:2]};
		2'b11:		N_shifted 	=	{ {(3){N_sum[DATA_LEN+4]}}, N_sum[DATA_LEN+4:3]};
	endcase
end

always_ff @(posedge clk)
begin
	if (rst)
		M <= {(DATA_LEN+5){1'b0}};
	else
		M <= ctrl[4] ? M_shifted : m_in;
end

always_ff @(posedge clk)
begin
	if (rst)
		N <= {(DATA_LEN+5){1'b0}};
	else
		N <= ctrl[4] ? N_shifted : n_in;
end

//  Shift Logic
logic [2:0] xm;
logic [2:0] xn;

always_comb begin
	case(Q_n1)
		2'b00:		xm = M_N_symbol ? 3'b001 : 3'b000;
		2'b01:		xm = {2'b0, M_N_2_0[0]};
		2'b10:		xm = {1'b0, M_N_2_0[1:0]};
		2'b11:		xm = M_N_2_0;
	endcase
end

always_comb begin
	case(xm)
		3'b000:		xpm = 261'h0;
		3'b001:		xpm = 261'h00fffffffeffffffffffffffffffffffffffffffff00000000ffffffffffffffff;
		3'b010:		xpm = 261'h01fffffffdfffffffffffffffffffffffffffffffe00000001fffffffffffffffe;
		3'b011:		xpm = 261'h02fffffffcfffffffffffffffffffffffffffffffd00000002fffffffffffffffd;
		3'b100:		xpm = 261'h03fffffffbfffffffffffffffffffffffffffffffc00000003fffffffffffffffc;
		3'b101:		xpm = 261'h04fffffffafffffffffffffffffffffffffffffffb00000004fffffffffffffffb;
		3'b110:		xpm = 261'h05fffffff9fffffffffffffffffffffffffffffffa00000005fffffffffffffffa;
		3'b111:		xpm = 261'h06fffffff8fffffffffffffffffffffffffffffff900000006fffffffffffffff9;
	endcase
end

always_comb begin
	case(Q_n2)
		2'b00:		xn = MN_symbol ? 3'b001 : 3'b000;
		2'b01:		xn = {2'b0, MN_2_0[0]};
		2'b10:		xn = {1'b0, MN_2_0[1:0]};
		2'b11:		xn = MN_2_0;
	endcase
end

always_comb begin
	case(xn)
		3'b000:		xpn = 261'h0;
		3'b001:		xpn = 261'h00fffffffeffffffffffffffffffffffffffffffff00000000ffffffffffffffff;
		3'b010:		xpn = 261'h01fffffffdfffffffffffffffffffffffffffffffe00000001fffffffffffffffe;
		3'b011:		xpn = 261'h02fffffffcfffffffffffffffffffffffffffffffd00000002fffffffffffffffd;
		3'b100:		xpn = 261'h03fffffffbfffffffffffffffffffffffffffffffc00000003fffffffffffffffc;
		3'b101:		xpn = 261'h04fffffffafffffffffffffffffffffffffffffffb00000004fffffffffffffffb;
		3'b110:		xpn = 261'h05fffffff9fffffffffffffffffffffffffffffffa00000005fffffffffffffffa;
		3'b111:		xpn = 261'h06fffffff8fffffffffffffffffffffffffffffff900000006fffffffffffffff9;
	endcase
end

assign U_eq1 = (U == 256'd1) ? 1'b1 : 1'b0;

endmodule