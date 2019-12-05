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

module adder_propagate 
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16,
	parameter DATA_LEN				= 256
)
(
	input logic [BIT_LEN-1:0] A[NUM_ELEMENTS],
	output logic [DATA_LEN-1:0] Propagated_A
);

localparam p = 256'hfffffffeffffffffffffffffffffffffffffffff00000000ffffffffffffffff;

logic [DATA_LEN+1:0] sum_out;
logic [DATA_LEN+1:0] np;
logic [1:0] borrow;

always_comb begin
	sum_out = { (DATA_LEN+1){1'b0} };
	for (int i = 0; i < NUM_ELEMENTS; i++) begin: sum_out_A
		sum_out = sum_out + (A[i] << (16*i));
	end
end

always_comb begin
	case(sum_out[DATA_LEN+1 : DATA_LEN])
		2'b00:		np = 258'h0;
		2'b01:		np = 258'h0fffffffeffffffffffffffffffffffffffffffff00000000ffffffffffffffff;
		2'b10:		np = 258'h1fffffffdfffffffffffffffffffffffffffffffe00000001fffffffffffffffe;
		2'b11:		np = 258'h2fffffffcfffffffffffffffffffffffffffffffd00000002fffffffffffffffd;
	endcase
end

assign {borrow, Propagated_A} = sum_out - np;

endmodule
		
