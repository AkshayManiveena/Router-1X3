module router_fifo(clock,resetn,write_enb,
				soft_reset,read_enb,data_in,lfd_state,
				data_out,empty,full);
	
	parameter
		WIDTH = 8,
		DEPTH =16,
		LENGTH=4;
	input [WIDTH-1:0]data_in;
	input clock,resetn,write_enb,read_enb,soft_reset;
	input lfd_state;
	output reg[WIDTH-1:0] data_out;
	output full,empty;
	integer i,flag;
	reg [5:0] payload;
	
	reg [LENGTH:0] read_pointer,write_pointer;

	reg[WIDTH:0] mem[0:DEPTH-1];

	reg lfd_state_reg;

	always @(posedge clock)
		begin	  
			if(~resetn || soft_reset)
					lfd_state_reg <= 1'b0;
		 	else 
					lfd_state_reg <= lfd_state;
		end


	always@(posedge clock)
		begin
			if(~resetn||soft_reset)
				begin
					for(i=0;i<DEPTH;i=i+1)
					begin
						mem[i]<=0;
					end
						write_pointer<=0;
				//data_out<=(resetn)?8'bz:8'd0;
				end
			else if(write_enb&&~full)
				begin
					mem[write_pointer[LENGTH-1:0]]<={lfd_state_reg,data_in};
					write_pointer<=write_pointer+1'b1;
				end
			else
					mem[write_pointer[LENGTH-1:0]]<=mem[write_pointer[LENGTH-1:0]];
			/*if(read_enb&&~empty)
				read();
			else
				data_out<=data_out;*/
				
				
		end
		always@(posedge clock)
		begin
			if(~resetn||soft_reset) begin 
				read_pointer <=1'b0;
				data_out<=(resetn)?8'bz:8'd0;
				payload <= 7'bzzz;
				end
			else if(read_enb&&~empty)
			begin
				if(mem[read_pointer[3:0]][8]==1'b1)
				begin
					payload<=mem[read_pointer[3:0]][7:2]+1'b1;
					data_out<=mem[read_pointer[3:0]][7:0];
					read_pointer<=read_pointer+1'b1;
				end
				else if(payload!=0)
				begin
					data_out<=mem[read_pointer[3:0]][7:0];
					payload<=payload-1'b1;
					read_pointer<=read_pointer+1'b1;
				end
				end
				else if(payload==0)
						  data_out<=8'bz;
		
			else
					  data_out<=data_out;
	
		end
		/*always@(posedge clock)
			begin
				if(payload==0)
					data_out<=8'bz;
		 		else
						  data_out<=data_out;
			end*/
	assign empty = (write_pointer==read_pointer)? 1'b1:1'b0;
	assign full = (write_pointer[LENGTH]!=read_pointer[LENGTH])&&(write_pointer[LENGTH-1:0]==read_pointer[LENGTH-1:0])?1'b1 : 1'b0;

endmodule
			
				
		

