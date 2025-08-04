module router_top(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,
			valid_out_1,valid_out_2,error,busy);

		input clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
		input [7:0] data_in;
		output[7:0] data_out_0,data_out_1,data_out_2;
		output valid_out_0,valid_out_1,valid_out_2,error,busy;
		
		
		wire [2:0] write_enb,empty,full,soft_reset;
		wire lfd_state,detect_add,write_enb_reg,fifo_full,parity_done,low_pkt_valid,ld_state,laf_state,full_state,rst_int_reg;
		wire [7:0] dout;
		
		router_fifo fifo_0(clock,resetn,write_enb[0],soft_reset[0],read_enb_0,dout,lfd_state,data_out_0,empty[0],full[0]);
		router_fifo fifo_1(clock,resetn,write_enb[1],soft_reset[1],read_enb_1,dout,lfd_state,data_out_1,empty[1],full[1]);
		router_fifo fifo_2(clock,resetn,write_enb[2],soft_reset[2],read_enb_2,dout,lfd_state,data_out_2,empty[2],full[2]);

		router_sync sync(clock,resetn,detect_add,data_in[1:0],write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full[0],full[1],full[2],empty[0],empty[1],empty[2],valid_out_0,valid_out_1,valid_out_2,soft_reset[0],soft_reset[1],soft_reset[2],fifo_full,write_enb);


		router_fsm fsm(clock,resetn,pkt_valid,parity_done,soft_reset[0],soft_reset[1],soft_reset[2],fifo_full,low_pkt_valid,empty[0],empty[1],empty[2],data_in[1:0],busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
		

		router_register register(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,error,dout);

	
endmodule

