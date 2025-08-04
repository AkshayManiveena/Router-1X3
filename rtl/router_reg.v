module router_register(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout);

		input [7:0] data_in;
		input clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
		output reg [7:0] dout;
		output reg parity_done,low_pkt_valid,err;

		reg[7:0] header_byte,fifo_full_state,internal_parity,packet_parity;

			//Data out 
		always@(posedge clock)
		begin
				if(~resetn)
				begin
						dout<=0;
						header_byte<=0;
						fifo_full_state<=0;
				end

				else if(detect_add && pkt_valid && data_in[1:0]!=3)
						header_byte<=data_in;
				else if(lfd_state)
						dout<=header_byte;
				else if(ld_state&&!fifo_full)
						dout<=data_in;
				else if(ld_state && fifo_full)
						fifo_full_state<=data_in;
				else if(laf_state)
						dout<=fifo_full_state;
		end

		//error logic
		
		always@(posedge clock)
		begin
				if(~resetn)
						err<=0;
				else if(internal_parity == packet_parity)
						err<=0;
				else
						err<=1;
		end

		//parity calculation
		
		always@(posedge clock)
		begin
				if(~resetn)
						internal_parity<=0;
				else if(detect_add)
						internal_parity<=0;
				else if(lfd_state)
						internal_parity<= internal_parity ^ header_byte;
				else if(ld_state && pkt_valid && !full_state)
						internal_parity <= internal_parity ^ data_in;
				else
						internal_parity <= internal_parity;
		end

		//parity done

		always@(posedge clock)
		begin
				if(~resetn)
						parity_done<=0;
				else if(detect_add)
						parity_done<=0;
				else if((ld_state && !fifo_full && !pkt_valid)||(laf_state && low_pkt_valid && !parity_done))
						parity_done<=1;
		end

		//low packet valid

		always@(posedge clock)
		begin
				if(~resetn)
						low_pkt_valid <= 0;
				else if (rst_int_reg)
						low_pkt_valid <= 0;
				else if(ld_state && !pkt_valid)
						low_pkt_valid <=1;
		end

		//packet parity

		always@(posedge clock)
		begin
				if(~resetn)
						packet_parity<=0;
				else if(detect_add)
						packet_parity<=0;
				else if(ld_state && ~pkt_valid)/*(ld_state && !fifo_full && !pkt_valid)||(laf_state && !parity_done && low_pkt_valid))*/
						packet_parity<=data_in;
		end

endmodule



