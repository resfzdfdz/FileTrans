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

localparam P_16 = 272'h001fffffffdfffffffffffffffffffffffffffffffe00000001fffffffffffffffe0;

logic [BIT_LEN-1:0] np[NUM_ELEMENTS];
genvar i;
generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: np_i
		assign np[i] = {1'b0, P_16[16*(i+1)-1 -: 16]};
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

generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: SUM_OUT
		if (i == 0)
			assign SUB[i] = { {(BIT_LEN-WORD_LEN){1'b0}}, borrow_out[i][WORD_LEN-1:0] };
		else
			assign SUB[i] = { {(BIT_LEN-WORD_LEN){1'b0}}, borrow_out[i][WORD_LEN-1:0] } +
								{{(WORD_LEN-EXTRA_BIT){1'b0}}, borrow_out[i-1][SUB_BIT-1:WORD_LEN] };
	end
endgenerate

endmodule

