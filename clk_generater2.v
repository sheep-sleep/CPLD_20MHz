module clk_generater2 (clk_in,rst,clk_gps);

input clk_in;   //1.023MHz 输入时钟
input rst;
output reg clk_gps; //50Hz 导航电文时钟
reg clk_reg;

reg [19:0] count1;

always @ (posedge clk_in or negedge rst)
begin
	if (!rst)
		begin
			count1 <= 0;
			clk_reg <= 0;
		end
		else begin
	if (count1 == 10229)//采用计数器进行分频
		begin
			count1 <= 0;
			clk_reg <= ~clk_reg;
		end
	else begin
			count1 <= count1+20'h1;
			clk_reg <= clk_reg;
	end
	clk_gps <= clk_reg;
	end
end

endmodule
