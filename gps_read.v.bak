module gps_read (clk,rst,gps_data_all,gps_data);

input clk,rst;
input [199:0] gps_data_all;
output reg gps_data;
reg [199:0] data_rom;

always @ (posedge clk or negedge rst)
begin
	if (!rst)
		begin
			gps_data <= 1'b0;
			//data_rom <= 200'h1000000020030040050666;//200比特的导航电文存储
			data_rom <= gps_data_all;
		end
	else begin
		gps_data <= data_rom[199];
//		data_rom <= data_rom <<1;
	   data_rom <= {data_rom[198:0],data_rom[199]};
	end

end
endmodule



