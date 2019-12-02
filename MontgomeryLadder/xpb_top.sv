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

module xpb_top
#(
	parameter REDUCT_SEGMENT	= 19,
	parameter NONREDUCT_SEGMENT = 16,
	parameter WORD_LEN			= 16,
	parameter BIT_LEN			= 17
)
(
	input logic [BIT_LEN-1:0] high19_segment[REDUCT_SEGMENT],
	output logic [BIT_LEN-1:0] all_xpb[3*REDUCT_SEGMENT][NONREDUCT_SEGMENT]
);

logic [4:0] lsbs [REDUCT_SEGMENT];
logic [5:0] csbs [REDUCT_SEGMENT];
logic [5:0] msbs [REDUCT_SEGMENT];

always_comb begin
	for (int i = 0; i < REDUCT_SEGMENT; i++)
		{msbs[i], csbs[i], lsbs[i]} = high19_segment[i];
end

logic [NONREDUCT_SEGMENT-1:0][WORD_LEN-1:0] xpbs[3*REDUCT_SEGMENT];

xpb_16_lsb xpb_16_lsb ( .x(lsbs[0]), .xpb(xpbs[0]) );
xpb_16_csb xpb_16_csb ( .x(csbs[0]), .xpb(xpbs[1]) );
xpb_16_msb xpb_16_msb ( .x(msbs[0]), .xpb(xpbs[2]) );
xpb_17_lsb xpb_17_lsb ( .x(lsbs[1]), .xpb(xpbs[3]) );
xpb_17_csb xpb_17_csb ( .x(csbs[1]), .xpb(xpbs[4]) );
xpb_17_msb xpb_17_msb ( .x(msbs[1]), .xpb(xpbs[5]) );
xpb_18_lsb xpb_18_lsb ( .x(lsbs[2]), .xpb(xpbs[6]) );
xpb_18_csb xpb_18_csb ( .x(csbs[2]), .xpb(xpbs[7]) );
xpb_18_msb xpb_18_msb ( .x(msbs[2]), .xpb(xpbs[8]) );
xpb_19_lsb xpb_19_lsb ( .x(lsbs[3]), .xpb(xpbs[9]) );
xpb_19_csb xpb_19_csb ( .x(csbs[3]), .xpb(xpbs[10]) );
xpb_19_msb xpb_19_msb ( .x(msbs[3]), .xpb(xpbs[11]) );
xpb_20_lsb xpb_20_lsb ( .x(lsbs[4]), .xpb(xpbs[12]) );
xpb_20_csb xpb_20_csb ( .x(csbs[4]), .xpb(xpbs[13]) );
xpb_20_msb xpb_20_msb ( .x(msbs[4]), .xpb(xpbs[14]) );
xpb_21_lsb xpb_21_lsb ( .x(lsbs[5]), .xpb(xpbs[15]) );
xpb_21_csb xpb_21_csb ( .x(csbs[5]), .xpb(xpbs[16]) );
xpb_21_msb xpb_21_msb ( .x(msbs[5]), .xpb(xpbs[17]) );
xpb_22_lsb xpb_22_lsb ( .x(lsbs[6]), .xpb(xpbs[18]) );
xpb_22_csb xpb_22_csb ( .x(csbs[6]), .xpb(xpbs[19]) );
xpb_22_msb xpb_22_msb ( .x(msbs[6]), .xpb(xpbs[20]) );
xpb_23_lsb xpb_23_lsb ( .x(lsbs[7]), .xpb(xpbs[21]) );
xpb_23_csb xpb_23_csb ( .x(csbs[7]), .xpb(xpbs[22]) );
xpb_23_msb xpb_23_msb ( .x(msbs[7]), .xpb(xpbs[23]) );
xpb_24_lsb xpb_24_lsb ( .x(lsbs[8]), .xpb(xpbs[24]) );
xpb_24_csb xpb_24_csb ( .x(csbs[8]), .xpb(xpbs[25]) );
xpb_24_msb xpb_24_msb ( .x(msbs[8]), .xpb(xpbs[26]) );
xpb_25_lsb xpb_25_lsb ( .x(lsbs[9]), .xpb(xpbs[27]) );
xpb_25_csb xpb_25_csb ( .x(csbs[9]), .xpb(xpbs[28]) );
xpb_25_msb xpb_25_msb ( .x(msbs[9]), .xpb(xpbs[29]) );
xpb_26_lsb xpb_26_lsb ( .x(lsbs[10]), .xpb(xpbs[30]) );
xpb_26_csb xpb_26_csb ( .x(csbs[10]), .xpb(xpbs[31]) );
xpb_26_msb xpb_26_msb ( .x(msbs[10]), .xpb(xpbs[32]) );
xpb_27_lsb xpb_27_lsb ( .x(lsbs[11]), .xpb(xpbs[33]) );
xpb_27_csb xpb_27_csb ( .x(csbs[11]), .xpb(xpbs[34]) );
xpb_27_msb xpb_27_msb ( .x(msbs[11]), .xpb(xpbs[35]) );
xpb_28_lsb xpb_28_lsb ( .x(lsbs[12]), .xpb(xpbs[36]) );
xpb_28_csb xpb_28_csb ( .x(csbs[12]), .xpb(xpbs[37]) );
xpb_28_msb xpb_28_msb ( .x(msbs[12]), .xpb(xpbs[38]) );
xpb_29_lsb xpb_29_lsb ( .x(lsbs[13]), .xpb(xpbs[39]) );
xpb_29_csb xpb_29_csb ( .x(csbs[13]), .xpb(xpbs[40]) );
xpb_29_msb xpb_29_msb ( .x(msbs[13]), .xpb(xpbs[41]) );
xpb_30_lsb xpb_30_lsb ( .x(lsbs[14]), .xpb(xpbs[42]) );
xpb_30_csb xpb_30_csb ( .x(csbs[14]), .xpb(xpbs[43]) );
xpb_30_msb xpb_30_msb ( .x(msbs[14]), .xpb(xpbs[44]) );
xpb_31_lsb xpb_31_lsb ( .x(lsbs[15]), .xpb(xpbs[45]) );
xpb_31_csb xpb_31_csb ( .x(csbs[15]), .xpb(xpbs[46]) );
xpb_31_msb xpb_31_msb ( .x(msbs[15]), .xpb(xpbs[47]) );
xpb_32_lsb xpb_32_lsb ( .x(lsbs[16]), .xpb(xpbs[48]) );
xpb_32_csb xpb_32_csb ( .x(csbs[16]), .xpb(xpbs[49]) );
xpb_32_msb xpb_32_msb ( .x(msbs[16]), .xpb(xpbs[50]) );
xpb_33_lsb xpb_33_lsb ( .x(lsbs[17]), .xpb(xpbs[51]) );
xpb_33_csb xpb_33_csb ( .x(csbs[17]), .xpb(xpbs[52]) );
xpb_33_msb xpb_33_msb ( .x(msbs[17]), .xpb(xpbs[53]) );
xpb_34_lsb xpb_34_lsb ( .x(lsbs[18]), .xpb(xpbs[54]) );
xpb_34_csb xpb_34_csb ( .x(csbs[18]), .xpb(xpbs[55]) );
xpb_34_msb xpb_34_msb ( .x(msbs[18]), .xpb(xpbs[56]) );

genvar i, j;
generate 
	for (i = 0; i < 3*REDUCT_SEGMENT; i++) begin: all_xpbs_i
		for (j = 0; j < NONREDUCT_SEGMENT; j++) begin: all_xpbs_j
			assign all_xpb[i][j] = { {(BIT_LEN-WORD_LEN){1'b0} }, xpbs[i][j] };
		end
	end
endgenerate

endmodule