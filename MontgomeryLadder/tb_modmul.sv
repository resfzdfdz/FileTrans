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

module tb_modmul;

parameter NUM_ELEMENTS          = 17;
parameter BIT_LEN               = 17;
parameter WORD_LEN              = 16;

parameter REDUCT_SEGMENT		= 19;
parameter NONREDUCT_SEGMENT		= 16;

parameter PERIOD				= 2;

logic [BIT_LEN-1:0] A[NUM_ELEMENTS];
logic [BIT_LEN-1:0] B[NUM_ELEMENTS];
logic [BIT_LEN-1:0] C[NUM_ELEMENTS];

logic [BIT_LEN-1:0] D[NUM_ELEMENTS];
logic [BIT_LEN-1:0] E[NUM_ELEMENTS];

logic clk = 0;
logic rst;

modmul #(
	.NUM_ELEMENTS		(	NUM_ELEMENTS		),
	.BIT_LEN			(	BIT_LEN				),
	.WORD_LEN			(	WORD_LEN			),
	.REDUCT_SEGMENT		(	REDUCT_SEGMENT		),
	.NONREDUCT_SEGMENT	(	NONREDUCT_SEGMENT	)
)	modmul (
	.clk				(		clk				),
	.rst				(		rst				),
	.A					(		A				),
	.B					(		B				),
	.C					(		C				)
);

logic [BIT_LEN-1:0] Ain[NUM_ELEMENTS][4];

genvar i;
generate 
	for (i = 0; i < NUM_ELEMENTS; i++) begin: Ain_i
		assign Ain[i][0] = A[i];
		assign Ain[i][1] = B[i];
		assign Ain[i][2] = 17'b0;
		assign Ain[i][3] = 17'b0;
	end
endgenerate

modadd #(
	.NUM_ELEMENTS		(	NUM_ELEMENTS		),
	.BIT_LEN			(	BIT_LEN				),
	.WORD_LEN			(	WORD_LEN			),
	.NUM_ADD			(		4				)
	)	modadd(
	.A					(		Ain				),
	.SUM				(		D				)
);

modsub #(
	.NUM_ELEMENTS		(	NUM_ELEMENTS		),
	.BIT_LEN			(	BIT_LEN				),
	.WORD_LEN			(	WORD_LEN			)
	)	modsub(
	.A					(		A				),
	.B					(		B				),
	.SUB				(		E				)
);

localparam P = 256'hFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF;

logic [NUM_ELEMENTS*WORD_LEN-1:0] A_p;
logic [NUM_ELEMENTS*WORD_LEN-1:0] B_p;

// Multiplier Outputs
logic [2*NUM_ELEMENTS*WORD_LEN-1:0] actual_result;
logic [2*NUM_ELEMENTS*WORD_LEN-1:0] expect_result;

// Generate clock
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

// Generate Reset
initial begin
	rst = 1;
	#(PERIOD*2) rst = 0;
end

// Generate Random Number
always@(posedge clk) begin
    A_p <= {$random, $random, $random, $random, $random, $random, $random, $random, $random, $random};
    B_p <= {$random, $random, $random, $random, $random, $random, $random, $random, $random, $random};
    $display("actual_result = %h\nexpect_result = %h\n", actual_result, expect_result);
end

// 256bit integer --> 17 segments 

generate
    for (i = 0; i < NUM_ELEMENTS; i++) begin
        assign A[i] = {1'b0, A_p[16*(i+1)-1 : 16*i] };
        assign B[i] = {1'b0, B_p[16*(i+1)-1 : 16*i] };
    end
endgenerate

// Get expect result
assign expect_result = A_p * B_p % P;

// Get actual result
logic [2*NUM_ELEMENTS*WORD_LEN-1:0] acc_result;
always @(posedge clk) 
begin
  #1;
	acc_result = 0;
	for (int j = 0; j < NUM_ELEMENTS; j++) begin
		acc_result = acc_result + (C[j] << (16*j) );
	end
end

assign actual_result = acc_result % P;

initial
begin
    #(PERIOD*3)
    #(PERIOD*300)
    $stop;
end

endmodule