module cputest();

reg clk;
wire [31:0] data;
wire [11:0] adr;
wire we;
cpu CPU(clk,data,adr,we);
ramprog ram(adr,we,data);

initial begin
	clk = 0;
end

always begin #10 clk = ~clk; end
always @(posedge clk) begin
	$display($time,,"  address = %b, data = %b, we = %b\n", adr,data,we);
end
endmodule
