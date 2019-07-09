module STM32_CPLD_SPI(
	main_clk,
	spi_clk,
	spi_cs, 
	spi_mosi, //MOSI
	spi_miso, //MISO
	led,
	gps_data_all
);

input  main_clk;
input  spi_clk;
input  spi_cs;
input  spi_mosi; //MOSI
output spi_miso; //MISO
output led;

//LED指示模块
reg [24:0] led_cnt = 0;
always @(posedge main_clk)
  led_cnt <= led_cnt + 1'b1;
assign led = led_cnt[24];  

//寄存器读写操作
parameter REG_ADDR = 8'h00; //写寄存器操作，25个寄存器，依次加1  0x00~0x18   
parameter REG_ADDR_READ = 8'h19;  //读寄存器操作，d25
parameter ReadStatusAddr =8'h1A; //写数据结束标志位寄存器地址  d26
//26个8bit的寄存器
reg [7:0] ARM_FPGA_REG[26:0];//第25个寄存器做为写数据结束标志寄存器

//时钟同步模块
reg  spi_clk_tmp1 = 0;
reg  spi_clk_tmp2 = 0;
reg  spi_clk_tmp3 = 0;

always @(posedge main_clk) //3级同步，比较可靠，2级也可以
begin
    spi_clk_tmp1 <= spi_clk;
    spi_clk_tmp2 <= spi_clk_tmp1;
    spi_clk_tmp2 <= spi_clk;
    spi_clk_tmp3 <= spi_clk_tmp2;
end

//跳变沿捕获
wire spi_clk_pos = ( ~spi_clk_tmp3 ) & spi_clk_tmp2;  //上升沿
wire spi_clk_neg = ( ~spi_clk_tmp2 ) & spi_clk_tmp3;  //下降沿

reg [2:0] state = 0;//状态标志位
reg [7:0] cmd_reg = 0;//命令
reg [7:0] out_data = 0;
reg [2:0] cnt = 0;
//数据传入
reg  spi_mosi_tmp1 = 0;
reg  spi_mosi_tmp2 = 0;

always @( posedge main_clk )
begin
    spi_mosi_tmp1 <= spi_mosi;                
    spi_mosi_tmp2 <= spi_mosi_tmp1;   
    spi_mosi_tmp2 <= spi_mosi;            
end

always @( posedge main_clk )               
begin
	if( ~spi_cs )//片选拉低  
		case( state )
			/*************************写地址操作******************************/
			0:	if( spi_clk_pos )//上升沿写数据
					begin
					ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;//总线忙，ReadStatusAddr =8'h1A
					cmd_reg <= { cmd_reg[6:0], spi_mosi_tmp2 }; //由低到高写入8位地址
					cnt <= cnt + 1'b1;
					if( cnt == 7 )
						begin
						cnt <= 0;
						state <= 1;  //接下来写数据
						ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;//总线空闲
						end
					end

			1:  begin
					case( cmd_reg )
					    /**************写数据操作*********************/	
						REG_ADDR:
							if( spi_clk_pos ) //写FPGA寄存器是上升沿  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR] <= {ARM_FPGA_REG[REG_ADDR][6:0],spi_mosi_tmp2};//由低到高写入8位数据 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;//写完数据，返回写其他地址或者写入要读取
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 1'd1:
							if( spi_clk_pos )
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+1'd1] <= {ARM_FPGA_REG[REG_ADDR+1'd1][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 2'd2:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+2'd2] <= {ARM_FPGA_REG[REG_ADDR+2'd2][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;    
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;									
									end
								end
						REG_ADDR + 2'd3:
							if( spi_clk_pos )
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+2'd3] <= {ARM_FPGA_REG[REG_ADDR+2'd3][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;									
									end
								end
						REG_ADDR + 3'd4:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+3'd4] <= {ARM_FPGA_REG[REG_ADDR+3'd4][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 3'd5:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+3'd5] <= {ARM_FPGA_REG[REG_ADDR+3'd5][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 3'd6:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+3'd6] <= {ARM_FPGA_REG[REG_ADDR+3'd6][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 3'd7:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+3'd7] <= {ARM_FPGA_REG[REG_ADDR+3'd7][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 4'd8:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+4'd8] <= {ARM_FPGA_REG[REG_ADDR+4'd8][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 4'd9:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+4'd9] <= {ARM_FPGA_REG[REG_ADDR+4'd9][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 4'd10:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+4'd10] <= {ARM_FPGA_REG[REG_ADDR+4'd10][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 4'd11:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+4'd11] <= {ARM_FPGA_REG[REG_ADDR+4'd11][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 4'd12:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+4'd12] <= {ARM_FPGA_REG[REG_ADDR+4'd12][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;  
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 4'd13:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+4'd13] <= {ARM_FPGA_REG[REG_ADDR+4'd13][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 4'd14:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+4'd14] <= {ARM_FPGA_REG[REG_ADDR+4'd14][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 4'd15:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+4'd15] <= {ARM_FPGA_REG[REG_ADDR+4'd15][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;  
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 5'd16:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd16] <= {ARM_FPGA_REG[REG_ADDR+5'd16][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;  
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 5'd17:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd17] <= {ARM_FPGA_REG[REG_ADDR+5'd17][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 5'd18:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd18] <= {ARM_FPGA_REG[REG_ADDR+5'd18][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 5'd19:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd19] <= {ARM_FPGA_REG[REG_ADDR+5'd19][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 5'd20:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd20] <= {ARM_FPGA_REG[REG_ADDR+5'd20][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;  
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 5'd21:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd21] <= {ARM_FPGA_REG[REG_ADDR+5'd21][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						REG_ADDR + 5'd22:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd22] <= {ARM_FPGA_REG[REG_ADDR+5'd22][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;   
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;									
									end
								end
						REG_ADDR + 5'd23:
							if( spi_clk_pos )  
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd23] <= {ARM_FPGA_REG[REG_ADDR+5'd23][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0; 
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;									
									end
								end
						REG_ADDR + 5'd24:
							if( spi_clk_pos )
								begin
								ARM_FPGA_REG[ReadStatusAddr] <= 8'h80;
								ARM_FPGA_REG[REG_ADDR+5'd24] <= {ARM_FPGA_REG[REG_ADDR+5'd24][6:0],spi_mosi_tmp2}; 
								cnt <= cnt + 1'b1;
								if(cnt == 7)
									begin
									cnt <= 0;
									state <= 0;
									ARM_FPGA_REG[ReadStatusAddr] <= 8'h00;
									end
								end
						/**************读数据操作********************/
						REG_ADDR_READ: 
							if( spi_clk_neg )//读FPGA寄存器是下降沿
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd25];
								state <= 2;  //读完数据，接下来发送数据
								end
						REG_ADDR_READ + 1'd1:
							if( spi_clk_neg )
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd24];
								state <= 2;
								end
						REG_ADDR_READ + 2'd2: 
							if( spi_clk_neg )
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd23];
								state <= 2; 
								end       
						REG_ADDR_READ + 2'd3: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd22];
								state <= 2; 
								end
						REG_ADDR_READ + 3'd4: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd21];
								state <= 2; 
								end 
						REG_ADDR_READ + 3'd5: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd20];
								state <= 2; 
								end 
						REG_ADDR_READ + 3'd6: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd19];
								state <= 2; 
								end       
						REG_ADDR_READ + 3'd7: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd18];
								state <= 2; 
								end       
						REG_ADDR_READ + 4'd8: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd17];
								state <= 2; 
								end
						REG_ADDR_READ + 4'd9: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-5'd16];
								state <= 2; 
								end
						REG_ADDR_READ + 4'd10: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-4'd15];
								state <= 2; 
								end
						REG_ADDR_READ + 4'd11: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-4'd14];
								state <= 2; 
								end
						REG_ADDR_READ + 4'd12: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-4'd13];
								state <= 2; 
								end
						REG_ADDR_READ + 4'd13: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-4'd12];
								state <= 2; 
								end
						REG_ADDR_READ + 4'd14: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-4'd11];
								state <= 2; 
								end
						REG_ADDR_READ + 4'd15: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-4'd10];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd16: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-4'd9];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd17: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-4'd8];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd18: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-3'd7];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd19: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-3'd6];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd20: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-3'd5];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd21: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-3'd4];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd22: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-2'd3];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd23: 
							if( spi_clk_neg ) 
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-2'd2];
								state <= 2; 
								end
						REG_ADDR_READ + 5'd24: 
							if( spi_clk_neg )
								begin
								out_data <= ARM_FPGA_REG[REG_ADDR_READ-1'd1];
								state <= 2; 
								end
						////////////////////////////////////////////
						ReadStatusAddr + 5'd24://状态标志位 d50
							if( spi_clk_neg )
								begin
								out_data <= ARM_FPGA_REG[ReadStatusAddr];////8'h08;
								state <= 2;
								end
						default : state<= 0;
					endcase
                end
			/************发送数据******************/
			2:  begin
               if( spi_clk_neg )
						begin
						out_data <= {out_data[6:0],1'b0};//每次只发送最高位
						cnt <= cnt + 1'b1;
							if( cnt == 7 )
							begin
							cnt <= 0;
							state <= 0;//发送完成，返回接收地址
							end
						 end
               end

            default : state <= 0;
		endcase      
end

assign spi_miso = out_data[7];    //SPI发送，只发送最高位        

output wire [199:0] gps_data_all;
assign gps_data_all = {ARM_FPGA_REG[0],ARM_FPGA_REG[1],ARM_FPGA_REG[2],ARM_FPGA_REG[3],ARM_FPGA_REG[4],ARM_FPGA_REG[5],ARM_FPGA_REG[6],ARM_FPGA_REG[7],ARM_FPGA_REG[8],ARM_FPGA_REG[9],ARM_FPGA_REG[10],ARM_FPGA_REG[11],ARM_FPGA_REG[12],ARM_FPGA_REG[13],ARM_FPGA_REG[14],ARM_FPGA_REG[15],ARM_FPGA_REG[16],ARM_FPGA_REG[17],ARM_FPGA_REG[18],ARM_FPGA_REG[19],ARM_FPGA_REG[20],ARM_FPGA_REG[21],ARM_FPGA_REG[22],ARM_FPGA_REG[23],ARM_FPGA_REG[24]};

//assign gps_data_all = {ARM_FPGA_REG[24],ARM_FPGA_REG[23],ARM_FPGA_REG[22],ARM_FPGA_REG[21],ARM_FPGA_REG[20],ARM_FPGA_REG[19],ARM_FPGA_REG[18],ARM_FPGA_REG[17],ARM_FPGA_REG[16],ARM_FPGA_REG[15],ARM_FPGA_REG[14],ARM_FPGA_REG[13],ARM_FPGA_REG[12],ARM_FPGA_REG[11],ARM_FPGA_REG[10],ARM_FPGA_REG[9],ARM_FPGA_REG[8],ARM_FPGA_REG[7],ARM_FPGA_REG[6],ARM_FPGA_REG[5],ARM_FPGA_REG[4],ARM_FPGA_REG[3],ARM_FPGA_REG[2],ARM_FPGA_REG[1],ARM_FPGA_REG[0]};
////将写入CPLD的导航电文直接排好顺序输出

endmodule  

