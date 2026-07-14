module FIFO #(		
	parameter DATA_WIDTH=8,
	parameter DEPTH=8)
	(input clk,
	input rst,
	input wr_en,
	input rd_en,
	input [DATA_WIDTH-1:0]din,
	output [DATA_WIDTH-1:0]dout,
	output full,
	output empty,
	output reg[$clog2(DEPTH+1)-1:0]count
	);
localparam ADDR_WIDTH=$clog2(DEPTH);
reg[DATA_WIDTH-1:0] mem[0:DEPTH-1];
reg[ADDR_WIDTH-1:0] wr_ptr,rd_ptr;
always @(posedge clk or posedge rst) begin
if(rst)
	wr_ptr<=0;
	else if(wr_en && !full)
	begin
	mem[wr_ptr]<=din;
	wr_ptr<=wr_ptr+1;
	end
	end
	always @(posedge clk or posedge rst)
	begin
	if(rst)
		rd_ptr<=0;
	else if(rd_en && !empty)
		rd_ptr<=rd_ptr+1;
	end
	always@(posedge clk or posedge rst)
	begin
	if(rst)
	count<=0;
	else case({wr_en&& !full,rd_en && !empty})
	2'b10:count<=count+1;
	2'b01:count<=count-1;
	default:count<=count;
	endcase
	end
	assign dout=mem[rd_ptr];
	assign empty=(count==0);
	assign full=(count==DEPTH);
	endmodule


	
	
	

