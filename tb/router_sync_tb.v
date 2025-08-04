module router_sync_tb();
	reg clock,reset,detec_addr,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,
			full_0,full_1,full_2,write_enb_reg;
	reg [1:0] data_in;
	wire [2:0]write_enb;
	wire vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full;

	router_sync dut(clock,
		reset,detec_addr,data_in,
		write_enb_reg,read_enb_0,
		read_enb_1,read_enb_2,full_0,
		full_1,full_2,empty_0,empty_1,
		empty_2,vld_out_0,vld_out_1,vld_out_2,
		soft_reset_0,soft_reset_1,soft_reset_2,
		fifo_full,write_enb);
		
		always
			#10 clock=~clock;
	
	task initialize();
			begin
					{clock,reset,detec_addr,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,write_enb_reg}=0;
			end
	endtask

	task reset_dut();
			begin
					@(negedge clock)
						reset=1'b0;
					@(negedge clock)
						reset=1'b1;

			end
	endtask

	initial
	begin
			initialize;
			reset_dut;
			@(negedge clock)
				detec_addr=1'b1;
				data_in<=2'b10;
			@(negedge clock)
				detec_addr=1'b0;
			@(negedge clock)
				write_enb_reg=1'b1;
			@(negedge clock)
				{full_0,full_1,full_2}=3'b001;
			@(negedge clock)
				{empty_0,empty_1,empty_2}=3'b110;
			@(negedge clock)
				{read_enb_0,read_enb_1,read_enb_2}=3'b000;
				#1000 $finish;
	end
endmodule
