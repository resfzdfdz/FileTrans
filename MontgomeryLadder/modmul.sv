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

module modmul
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16,
	
	parameter REDUCT_SEGMENT		= 19,
	parameter NONREDUCT_SEGMENT		= 16
)
(
	input logic					clk,
	input logic					rst,
	input logic [BIT_LEN-1:0] A[NUM_ELEMENTS],
	input logic [BIT_LEN-1:0] B[NUM_ELEMENTS],
	output logic [BIT_LEN-1:0] C[NUM_ELEMENTS]
);

logic [BIT_LEN-1:0] M[NUM_ELEMENTS*2+1];
logic [BIT_LEN-1:0] M_reg[NUM_ELEMENTS*2+1];

multiplier_256 #(
	.NUM_ELEMENTS		(	NUM_ELEMENTS		),
	.BIT_LEN			(	BIT_LEN				),
	.WORD_LEN			(	WORD_LEN			)
	)	multiplier_256	(
	.A					(		A				),
	.B					(		B				),
	.M					(		M				)
);

localparam ZERO = 17'b0;
always_ff @(posedge clk)
begin
	if (rst)
		for (int i = 0; i < 2*NUM_ELEMENTS+1; i++) begin
			M_reg[i] <= ZERO;
		end
	else
		for (int i = 0; i < 2*NUM_ELEMENTS+1; i++) begin
			M_reg[i] <= M[i];
		end
end

logic [BIT_LEN-1:0] xpbs[3*REDUCT_SEGMENT][NONREDUCT_SEGMENT];
logic [BIT_LEN-1:0] high19_segment[REDUCT_SEGMENT];

genvar k;
generate
	for (k = 0; k < REDUCT_SEGMENT; k++) begin: high19_segs
		assign high19_segment[k] = M_reg[k+16];
	end
endgenerate

xpb_top #(
	.REDUCT_SEGMENT		(	REDUCT_SEGMENT		),
	.NONREDUCT_SEGMENT	(	NONREDUCT_SEGMENT	),
	.BIT_LEN			(	BIT_LEN				),
	.WORD_LEN			(	WORD_LEN			)
	)	xpb_top (
	.high19_segment		(	high19_segment 		),
	.all_xpb			(	xpbs				)
);

localparam EXTRA_BIT = $clog2(3*REDUCT_SEGMENT+1)+2;
localparam ACC_BIT = BIT_LEN + EXTRA_BIT;
     
logic [ACC_BIT-1:0] coefs [NONREDUCT_SEGMENT][3*REDUCT_SEGMENT+1];
genvar i, j;
generate 
	for (i = 0; i < NONREDUCT_SEGMENT; i++) begin: coefs_i
		for (j = 0; j < 3*REDUCT_SEGMENT+1; j++) begin: coef_j
			if (j == 3 * REDUCT_SEGMENT)
				assign coefs[i][j] = { {(EXTRA_BIT){1'b0}}, M_reg[i] };
			else
				assign coefs[i][j] =  { {(EXTRA_BIT){1'b0}}, xpbs[j][i] };
		end
	end
endgenerate

logic [ACC_BIT-1:0] acc_coefs [NONREDUCT_SEGMENT];

generate 
	for (i = 0; i < NONREDUCT_SEGMENT; i++) begin: acc_coefs_i
		/* adder_tree_58_to_1 #(
			.NUM_ELEMENTS			(	3*REDUCT_SEGMENT+1	),
			.BIT_LEN				(		ACC_BIT			)
		)	adder_tree_58_to_1 (
			.terms					(	coefs[i]			),
			.S						(	acc_coefs[i]		)
		); */
		adder_tree_2_to_1 #(
			.NUM_ELEMENTS			(	3*REDUCT_SEGMENT+1	),
			.BIT_LEN				(		ACC_BIT			)
		)	adder_tree_2_to_1 (
			.terms					(	coefs[i]			),
			.S						(	acc_coefs[i]		)
		);
	end
endgenerate

logic [BIT_LEN-1:0] reduced_coefs[NUM_ELEMENTS];
generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: reduced_coefs_i
		if (i == 0)
			assign reduced_coefs[i] = {1'b0, acc_coefs[0][WORD_LEN-1:0]};
		else if (i == NUM_ELEMENTS-1)
			assign reduced_coefs[i] = { {(WORD_LEN-EXTRA_BIT){1'b0}}, acc_coefs[i-1][ACC_BIT-1 : WORD_LEN] };
		else
			assign reduced_coefs[i] = {1'b0, acc_coefs[i][WORD_LEN-1:0]} + 
										{ {(WORD_LEN-EXTRA_BIT){1'b0}}, acc_coefs[i-1][ACC_BIT-1 : WORD_LEN]};
	end
endgenerate	
	
generate
	for (i = 0; i < NUM_ELEMENTS; i++) begin: Ci
		assign C[i] = reduced_coefs[i];
	end
endgenerate
	
endmodule



/* module adder_tree_58_to_1
   #(
     parameter int NUM_ELEMENTS      = 58,
     parameter int BIT_LEN           = 25
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] S
   );

	logic [BIT_LEN-1:0] level_1[29];
	
	genvar i;
	generate
		for (i = 0; i < 29; i++) begin: level_1_i
			assign level_1[i] = terms[2*i] + terms[2*i+1];
		end
	endgenerate
	
	logic [BIT_LEN-1:0] level_2[15];
	
	generate
		for (i = 0; i < 15; i++) begin: level_2_i
			if (i == 14)
				assign level_2[i] = level_1[28];
			else
				assign level_2[i] = level_1[2*i] + level_1[2*i+1];
		end
	endgenerate
	
	logic [BIT_LEN-1:0] level_3[8];
	
	generate
		for (i = 0; i < 8; i++) begin: level_3_i
			if (i == 7)
				assign level_3[i] = level_2[14];
			else
				assign level_3[i] = level_2[2*i] + level_2[2*i+1];
		end
	endgenerate	
	
	logic [BIT_LEN-1:0] level_4[4];
	
	generate
		for (i = 0; i < 4; i++) begin: level_4_i
			assign level_4[i] = level_3[2*i] + level_3[2*i+1];
		end
	endgenerate	
	
	logic [BIT_LEN-1:0] level_5[2];
	
	generate
		for (i = 0; i < 2; i++) begin: level_5_i
			assign level_5[i] = level_4[2*i] + level_4[2*i+1];
		end
	endgenerate	
	
	assign S = level_5[0] + level_5[1];
   
endmodule  */

module adder_tree_2_to_1
  #(
    parameter int NUM_ELEMENTS      = 9,
    parameter int BIT_LEN           = 16
   )
  (
   input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
   output logic [BIT_LEN-1:0] S
  );


  generate
     if (NUM_ELEMENTS == 1) begin // Return value
        always_comb begin
           S[BIT_LEN-1:0] = terms[0];
        end
     end else if (NUM_ELEMENTS == 2) begin // Return value
        always_comb begin
           S[BIT_LEN-1:0] = terms[0] + terms[1];
        end
     end else begin
        localparam integer NUM_RESULTS = integer'(NUM_ELEMENTS/2) + (NUM_ELEMENTS%2);
        logic [BIT_LEN-1:0] next_level_terms[NUM_RESULTS];

        adder_tree_level #(.NUM_ELEMENTS(NUM_ELEMENTS),
                           .BIT_LEN(BIT_LEN)
        ) adder_tree_level (
                           .terms(terms),
                           .results(next_level_terms)
        );

        adder_tree_2_to_1 #(.NUM_ELEMENTS(NUM_RESULTS),
                                 .BIT_LEN(BIT_LEN)
        ) adder_tree_2_to_1 (
                                 .terms(next_level_terms),
                                 .S(S)
        );
     end
  endgenerate
endmodule


module adder_tree_level
  #(
    parameter int NUM_ELEMENTS = 3,
    parameter int BIT_LEN      = 19,

    parameter int NUM_RESULTS  = integer'(NUM_ELEMENTS/2) + (NUM_ELEMENTS%2)
   )
  (
   input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
   output logic [BIT_LEN-1:0] results[NUM_RESULTS]
  );

  always_comb begin
     for (int i=0; i<(NUM_ELEMENTS / 2); i++) begin
        results[i] = terms[i*2] + terms[i*2+1];
     end

     if( NUM_ELEMENTS % 2 == 1 ) begin
        results[NUM_RESULTS-1] = terms[NUM_ELEMENTS-1];
     end
  end
endmodule