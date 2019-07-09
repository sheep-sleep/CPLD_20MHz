module crtl_generater (pps,rst,crtl_pps1);

input rst;
input pps;

output reg crtl_pps1;


reg crtl_pps_reg;

always @ (posedge pps)
begin
	if (!rst) 
		begin
		crtl_pps_reg <= 0;
		end
	else begin
		crtl_pps_reg <= ~crtl_pps_reg;	
	end
	
	crtl_pps1 = crtl_pps_reg;

end
endmodule