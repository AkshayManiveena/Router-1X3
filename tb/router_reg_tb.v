module router_reg_tb();
	reg [7:0] data_in;
	reg clock,reset,pkt_valid,fifo_full,rst_int_reg,detect_add, ld_state,laf_state,full_state,lfd_state;
	wire [7:0] dout;
	wire parity_done,low_pkt_valid,err;
	integer i;
	router_register dut(clock,reset,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout);


	always
			  #5 clock =~clock;

	task initialize;
			  {data_in,clock,reset,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state}=0;
	endtask

	task reset_dut;
			  begin
						 @(negedge clock)
						 reset =1'b0;
						 @(negedge clock)
						 reset=1'b1;
			 end
	endtask

	task packet_generation;
			  reg[7:0] payload_data, parity,header;
			  reg [5:0] payload_len;
			  reg [1:0] addr;

			  begin
						 @(negedge clock)
						 payload_len = 6'd1;
						 addr = 2'b10;
						 pkt_valid = 1'b1;
						 detect_add = 1'b1;
						 header = {payload_len,addr};
						 parity = 8'h00 ^ header;
						 data_in = header;
						 $monitor("h=%b, p=%b",header,parity);
						 	@(negedge clock)
							detect_add = 1'b0;
							lfd_state = 1'b1;
							full_state = 1'b0;
							fifo_full = 1'b0;
							laf_state = 1'b0;
						for(i=0;i<payload_len;i=i+1)
							begin
									  @(negedge clock)
									  lfd_state = 1'b0;
									  ld_state = 1'b1;
									  payload_data = {$random}%256;
									  data_in = payload_data;
									  parity = data_in ^ parity;
						end
						@(negedge clock)
						pkt_valid = 1'b0;
						data_in = parity;
						@(negedge clock)
						ld_state = 1'b0;
			end
	endtask

	initial
	begin
			  initialize;
			  reset_dut;
			  packet_generation;
			  #100 $finish;
	end
endmodule

