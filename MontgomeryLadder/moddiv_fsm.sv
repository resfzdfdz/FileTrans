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

module moddiv_fsm
#(
    parameter DATA_LEN		=	256,
	parameter CONT_LEN		=	30
)
(
	input logic 				clk,
	input logic 				rst,
	input logic 				start_div,
	input logic					U_eq1,
	input logic					bor2,
	input logic	[1:0]			n1,
	input logic	[1:0]			n2,
	output logic [0:CONT_LEN-1]	ctrl,
	output logic 				finish_div
);

enum {IDLE, PRE, LOOP, FINISH} state_now, state_next;

always_ff @(posedge clk)
begin
	if (rst)
		state_now <= IDLE;
	else
		state_now <= state_next;
end

always_comb begin
	case(state_now)
		IDLE:		state_next = start_div ? PRE : IDLE;
		PRE:		state_next = LOOP;
		LOOP:		state_next = U_eq1 ? FINISH : LOOP;
		FINISH:		state_next = IDLE;
		default:	state_next = IDLE;
	endcase
end

always_ff @(posedge clk)
begin
	case(state_next)
		IDLE:		ctrl <= 30'b0100_0_00_01010100_00_000100_00_00000;
		PRE:		ctrl <= 30'b1011_1_11_11010100_00_100100_00_00000;
		LOOP:		if (bor2 == 1'b1)
						ctrl <= {7'b1011111, 8'b11110001, n1, 6'b100110, n2, 5'b00000};
					else
						ctrl <= {7'b1011111, 8'b00111101, n1, 6'b010110, n2, 5'b00000};
/* 		LOOP:		if (Q_bor == 1'b1)
						ctrl <= {7'b1011111, 8'b11110001, Q_n1, 6'b100110, Q_n2, 5'b00000};
					else
						ctrl <= {7'b1011111, 8'b00111101, Q_n1, 6'b010110, Q_n2, 5'b00000}; */
		FINISH:		ctrl <= 30'b0100_1_00_11010100_00_100100_00_00000;
		default:	ctrl <= 30'b0100_1_00_11010100_00_100100_00_00000;
	endcase
end

assign finish_div = (state_now == FINISH);

endmodule