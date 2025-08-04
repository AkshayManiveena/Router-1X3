module router_fsm_tb();
	reg [1:0] data_in;
	reg clock, reset, pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2, fifo_full, low_pkt_valid,fifo_empty_0,fifo_empty_1,
				fifo_empty_2;

	wire busy, detect_add, ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;


	router_fsm dut(clock,reset,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,
					fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,data_in,
					busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

	always
			#5 clock = ~clock;

	task initialize;
			{clock,reset,pkt_valid,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2}=0;

	endtask

	task reset_dut;
			begin
					@(negedge clock)
						reset = 1'b0;
					@(negedge clock)
						reset =1'b1;
			end
	endtask

	task t1;
			begin
					@(negedge clock)
					pkt_valid=1'b1;
					data_in =2'b01;
					fifo_empty_1=1'b1;
					@(negedge clock)
					@(negedge clock)
					fifo_full=1'b0;
					pkt_valid=1'b0;
					@(negedge clock)
					@(negedge clock)
					fifo_full=1'b0;
			end
	endtask

	task t2;
			begin
					@(negedge clock)
					pkt_valid=1'b1;
					data_in=2'b01;
					fifo_empty_1=1'b1;
					@(negedge clock)
					@(negedge clock)
					fifo_full=1'b1;
					@(negedge clock)
					fifo_full=1'b0;
					@(negedge clock)
					parity_done=1'b0;
					low_pkt_valid=1'b1;
					@(negedge clock)
					@(negedge clock)
					fifo_full=1'b0;
			end
	endtask

	task t3;
			begin
					@(negedge clock)
					pkt_valid=1'b1;
					data_in=2'b01;
					fifo_empty_1=1'b1;
					@(negedge clock)
					@(negedge clock)
					fifo_full=1'b1;
					@(negedge clock)
					fifo_full=1'b0;
					@(negedge clock)
					parity_done=1'b0;
					low_pkt_valid=1'b0;
					@(negedge clock)
					fifo_full=1'b0;
					pkt_valid=1'b0;
					@(negedge clock)
					@(negedge clock)
					fifo_full=1'b0;
			end
	endtask

	task t4;
			begin
					@(negedge clock)
					pkt_valid=1'b1;
					data_in=2'b01;
					fifo_empty_1=1'b1;
					@(negedge clock)
					@(negedge clock)
					fifo_full=1'b0;
					pkt_valid=1'b0;
					@(negedge clock)
					@(negedge clock)
					fifo_full=1'b1;
					@(negedge clock)
					fifo_full=1'b0;
					@(negedge clock)
					parity_done=1'b1;
			end
	endtask

	initial
	begin
			initialize;
			//reset_dut;
			@(negedge clock) reset =1;
			t2;
			//#1000
			//t2;
			#1000 $finish;
	end
endmodule
