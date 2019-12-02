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

module tb_PAD;

parameter NUM_ELEMENTS          = 17;
parameter BIT_LEN               = 17;
parameter WORD_LEN              = 16;
parameter DATA_LEN				= 256;

logic clk, rst, start, finish;
logic [DATA_LEN-1:0] k; 
logic [DATA_LEN-1:0] x1; 
logic [DATA_LEN-1:0] y1;
logic [BIT_LEN-1:0] x3[NUM_ELEMENTS];
logic [BIT_LEN-1:0] z31[NUM_ELEMENTS];
logic [BIT_LEN-1:0] y3[NUM_ELEMENTS];
logic [BIT_LEN-1:0] z32[NUM_ELEMENTS];

PAD_fsm #(
	.NUM_ELEMENTS          	(	NUM_ELEMENTS	),
    .BIT_LEN               	(	BIT_LEN			),
    .WORD_LEN              	(	WORD_LEN		),
	.DATA_LEN				(	DATA_LEN		)
	) PAD_fsm (
	.clk					(		clk			),
	.rst					(		rst			),
	.start					(		start		),
	.k						(		k			),
	.x1						(		x1			),
	.y1						(		y1			),
	.x3						(		x3			),
	.z31					(		z31			),
	.y3						(		y3			),
	.z32					(		z32			),
	.finish					(		finish		)
);

//  Clock 
localparam HP = 5;
initial begin
	clk = 0;
	forever #(HP) clk = ~clk;
end

//  Reset
initial begin
	rst = 1;
	#(HP*4) rst = 0;
end

//  Basic Point G = (px, py)
initial begin
	x1 = 256'h32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7;
	y1 = 256'hBC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0;
end

//  Random k
logic [DATA_LEN-1:0] dk;
always @(posedge clk)
begin
	if (rst)
		dk <= 256'd20;
	else
		if (finish)
			dk <= {$random, $random, $random, $random, $random, $random, $random, $random};
		else
			dk <= dk;
end
assign k = dk;

//  Start 
always @(posedge clk)
begin
	if (rst)
		start <= 0;
	else
		if (finish) begin
			start <= 0;
			#(HP * 5) start <= 1;
			end
		else
			start <= 1;
end

localparam p = 256'hfffffffeffffffffffffffffffffffffffffffff00000000ffffffffffffffff;

function [290:0] redunt2int;
	input [BIT_LEN-1:0] din[NUM_ELEMENTS];
	begin
		redunt2int = 0;
		for (int i = 0; i < NUM_ELEMENTS; i++) begin
			redunt2int = redunt2int + (din[i] << (16*i));
		end
		redunt2int = redunt2int % p;
	end
endfunction

task print_result;
	input [BIT_LEN-1:0] din[NUM_ELEMENTS];
	logic [290:0] result;
	begin
		result = redunt2int(din);
		$display("%x\n", result);
	end
endtask

always @(posedge finish)
begin
	$display("k = %x\n", k);
	$display("x3 =");
	print_result(x3);
	$display("z31 =");
	print_result(z31);
	$display("y3 =");
	print_result(y3);
	$display("z32 =");
	print_result(z32);
end

endmodule