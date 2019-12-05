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

module modsub
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16
)
(
	input logic [BIT_LEN-1:0] A[NUM_ELEMENTS],
	input logic [BIT_LEN-1:0] B[NUM_ELEMENTS],
	output logic [BIT_LEN-1:0] SUB[NUM_ELEMENTS]
);

localparam P_32 = 272'h001fffffffdfffffffffffffffffffffffffffffffe00000001fffffffffffffffe0;
// localparam P_64 = 272'h003fffffffbfffffffffffffffffffffffffffffffc00000003fffffffffffffffc0;

logic [BIT_LEN-1:0] np[NUM_ELEMENTS];
// logic [BIT_LEN-1:0] np_final[NUM_ELEMENTS];

genvar i;
generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: np_i
		assign np[i] 		= {1'b0, P_32[16*(i+1)-1 -: 16]};
	end
endgenerate

localparam EXTRA_BIT = 2;
localparam SUB_BIT = BIT_LEN + EXTRA_BIT;
localparam REDUCT_ADD = 19'h30000;
localparam REDUCT_SUB = 19'h00003;

logic [SUB_BIT-1:0] borrow_out[NUM_ELEMENTS];
generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: borrow_out_i
		if (i == 0)
			assign borrow_out[i] = A[i] + np[i] - B[i] + REDUCT_ADD;
		else if (i == NUM_ELEMENTS-1)
			assign borrow_out[i] = A[i] + np[i] - B[i] - REDUCT_SUB;
		else
			assign borrow_out[i] = A[i] + np[i] - B[i] + REDUCT_ADD - REDUCT_SUB;
	end
endgenerate

logic [BIT_LEN-1:0] reduced_sub[NUM_ELEMENTS];

generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: reduced_sub_i
		if (i == 0)
			assign reduced_sub[i] = { {(BIT_LEN-WORD_LEN){1'b0}}, borrow_out[i][WORD_LEN-1:0] };
		else
			assign reduced_sub[i] = { {(BIT_LEN-WORD_LEN){1'b0}}, borrow_out[i][WORD_LEN-1:0] } +
								{{(WORD_LEN-EXTRA_BIT){1'b0}}, borrow_out[i-1][SUB_BIT-1:WORD_LEN] };
	end
endgenerate

logic [15:0][15:0] xpb;

xpb_addsub xpb_addsub(
	.x			(	reduced_sub[NUM_ELEMENTS-1][5:0]		),
	.xpb		(		xpb									)
);

logic [SUB_BIT-1:0] grid_sub[NUM_ELEMENTS-1];

generate
	for (i = 0; i < NUM_ELEMENTS-1; i++) begin: grid_sum_i
		assign grid_sub[i] = reduced_sub[i] + xpb[i];
	end
endgenerate

generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: SUB_i
		if (i == 0)
			assign SUB[i] = {1'b0, grid_sub[0][WORD_LEN-1:0]};
		else if (i == NUM_ELEMENTS-1)
				assign SUB[i] = { {(WORD_LEN-EXTRA_BIT){1'b0}}, grid_sub[i-1][SUB_BIT-1 : WORD_LEN]};
		else
			assign SUB[i] = { {(BIT_LEN-WORD_LEN){1'b0}}, grid_sub[i][WORD_LEN-1:0]} + 
										{ {(WORD_LEN-EXTRA_BIT){1'b0}}, grid_sub[i-1][SUB_BIT-1 : WORD_LEN]};
	end
endgenerate

endmodule

