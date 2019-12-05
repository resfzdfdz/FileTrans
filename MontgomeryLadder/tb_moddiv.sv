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

module tb_moddiv;

parameter DATA_LEN	=	256;
parameter CONT_LEN	=	30;
localparam P = 256'hFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF;

logic clk = 0;
logic rst = 1;
logic start_div = 0;
logic finish_div;

logic [DATA_LEN-1:0] u_in = 0;
logic [DATA_LEN-1:0] v_in = 0;
logic [DATA_LEN+4:0] m_in = 0;
logic [DATA_LEN+4:0] n_in = 0;

logic [DATA_LEN-1:0] U;
logic [DATA_LEN-1:0] V;
logic [DATA_LEN+4:0] M;
logic [DATA_LEN+4:0] N;

logic U_eq1;
logic bor2;
logic [1:0] n1;
logic [1:0] n2;

logic [0:CONT_LEN-1] ctrl;

moddiv #(
    .DATA_LEN				(	DATA_LEN	),
	.CONT_LEN				(	CONT_LEN	)
)	moddiv 
(
	.clk					(	clk			),	
	.rst					(	rst			),	
	.u_in					(	u_in		),	
	.v_in					(	v_in		),	
	.m_in					(	m_in		),	
	.n_in					(	n_in		),	
	.ctrl					(	ctrl		),	
	.U						(	U			),	
	.V						(	V			),	
	.M						(	M			),	
	.N						(	N			),	
	.U_eq1					(	U_eq1		),	
	.bor2					(	bor2		),	
	.n1						(	n1			),	
	.n2						(	n2			)
);

moddiv_fsm
#(
    .DATA_LEN				(	DATA_LEN	),
	.CONT_LEN				(	CONT_LEN	)
)	moddiv_fsm
(
	.clk					(	clk			),
	.rst					(	rst			),
	.start_div				(	start_div	),
	.U_eq1					(	U_eq1		),
	.bor2					(	bor2		),
	.n1						(	n1			),
	.n2						(	n2			),
	.ctrl					(	ctrl		),
	.finish_div				(	finish_div	)
);

localparam HP = 5;

always #(HP) clk = ~clk;

initial begin
	#(HP * 2) rst = 0;
end

initial begin
	#(HP * 5)
	@(posedge clk) begin
		u_in = 256'h8979de91648bbfab51f06344b4777f04904fbca27e8334a58a913060f32f88f;
		v_in = P;
		m_in = 256'h1a215adce2c34c0ebe9271a59d74c6c4c5bc9a4fd997208a7127cfa9abf4790c;
		n_in = 0;
		start_div = 1;
	end
	
	@(negedge finish_div)
		start_div = 0;
end

endmodule
		