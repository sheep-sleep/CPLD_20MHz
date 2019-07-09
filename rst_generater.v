module rst_generater (clk,pps,transmit_enble,gps_data_channel_number,rst,channel_number);//将1pps信号和传输使能进行判断，判断系统初始化

input clk;
input pps,transmit_enble;
input [3:0] gps_data_channel_number;

output reg rst;
output reg [3:0] channel_number;

always @ (posedge clk)
begin
	if (transmit_enble== 1)//其时序和文档要求一样
		begin
			if (pps == 1)
				begin
					rst <= 1;
					channel_number <= gps_data_channel_number;
				end
			else begin 
					rst <= rst;		
					channel_number <= channel_number;
				end
		end
	else begin
		rst <= 0;
		channel_number <= 4'b1111;
	end

end
endmodule
