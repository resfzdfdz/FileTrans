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

module modadd
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16,
	parameter NUM_ADD				= 4
)
(
	input logic [BIT_LEN-1:0] A[NUM_ELEMENTS][NUM_ADD],
	output logic [BIT_LEN-1:0] SUM[NUM_ELEMENTS]
);

localparam EXTRA_BIT = $clog2(NUM_ADD)+1;
localparam ACC_BIT = BIT_LEN + EXTRA_BIT;

genvar i, j;
logic [ACC_BIT-1:0] temp_A [NUM_ELEMENTS][NUM_ADD];
generate 
	for (i = 0; i < NUM_ELEMENTS; i++) begin: padding
		for (j = 0; j < NUM_ADD; j++) begin: padding_y
			assign temp_A[i][j] = { {(EXTRA_BIT){1'b0}}, A[i][j]};
		end
	end
endgenerate

logic [ACC_BIT-1:0] temp_sum [NUM_ELEMENTS];
generate 
	for (i = 0; i < NUM_ELEMENTS; i++) begin: adder_tree
		adder_tree_2_to_1 #(
			.NUM_ELEMENTS			(		NUM_ADD			),
			.BIT_LEN				(		ACC_BIT			)
		)	adder_tree_2_to_1 (
			.terms					(		temp_A[i]		),
			.S						(		temp_sum[i]		)
		);
	end
endgenerate

generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: reduce_add
		if (i == 0)
			assign SUM[i] = {1'b0, temp_sum[0][WORD_LEN-1:0]};
		else
			assign SUM[i] = { {(BIT_LEN-WORD_LEN){1'b0}}, temp_sum[i][WORD_LEN-1:0]} + 
										{ {(WORD_LEN-EXTRA_BIT){1'b0}}, temp_sum[i-1][ACC_BIT-1 : WORD_LEN]};
	end
endgenerate

endmodule