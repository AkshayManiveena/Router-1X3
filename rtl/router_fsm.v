module router_fsm(clock,reset,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,
					fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,data_in,
					busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

			input [1:0] data_in;
			input clock,reset,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,
					fifo_empty_0,fifo_empty_1,fifo_empty_2;
			output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;


			parameter
				DECODE_ADDRESS= 3'b000,
				LOAD_FIRST_DATA= 3'b001,
				WAIT_TILL_EMPTY= 3'b010,
				LOAD_DATA=3'b011,
				FIFO_FULL_STATE=3'b100,
				LOAD_AFTER_FULL=3'b101,
				LOAD_PARITY= 3'b110,
				CHECK_PARITY_ERROR= 3'b111;

		reg [2:0] state,next_state;
		reg [1:0] addr;

		always@(posedge clock)
				if(~reset)
						addr<=0;
				else if(pkt_valid)
						addr<=data_in;

		always@(posedge clock)
			begin
					if(~reset)
							state<=DECODE_ADDRESS;
					else if(soft_reset_0||soft_reset_1||soft_reset_2)
							state<=DECODE_ADDRESS;
					else
							state<=next_state;
			end

		always@(state or pkt_valid or addr or fifo_empty_0 or data_in or fifo_empty_1,fifo_empty_2 or fifo_full or low_pkt_valid or parity_done)
			begin
						next_state= DECODE_ADDRESS;
					case(state)
							DECODE_ADDRESS: if((pkt_valid&data_in==2'b00 & fifo_empty_0) ||( pkt_valid & data_in==2'b01 & fifo_empty_1)|
								   				(pkt_valid & data_in==2'b10 &fifo_empty_2))
											next_state=LOAD_FIRST_DATA;
											else if((pkt_valid & data_in==2'b00 & !fifo_empty_0) || (pkt_valid & data_in==2'b01 & !fifo_empty_1)	||(pkt_valid & data_in==2'b10 & !fifo_empty_2)												||(pkt_valid & addr==2'b10 & !fifo_empty_2))
											next_state=WAIT_TILL_EMPTY;
											else
													next_state=DECODE_ADDRESS;
							LOAD_FIRST_DATA: next_state=LOAD_DATA;
							WAIT_TILL_EMPTY: if((fifo_empty_0 && addr==2'b00)||(fifo_empty_1 && addr==2'b01)||(fifo_empty_2 &&addr==2'b10))
												next_state=LOAD_FIRST_DATA;
											 else
													 next_state=WAIT_TILL_EMPTY;
							LOAD_DATA: if(fifo_full)
												next_state=FIFO_FULL_STATE;
											else if(!fifo_full && !pkt_valid)
													next_state=LOAD_PARITY;
											else
													next_state=LOAD_DATA;
							FIFO_FULL_STATE: if(!fifo_full)
												next_state=LOAD_AFTER_FULL;
											else 
												next_state=FIFO_FULL_STATE;
							LOAD_AFTER_FULL: if((!parity_done) && (low_pkt_valid))
												next_state=LOAD_PARITY;
											else if((!parity_done)&& (!low_pkt_valid))
													next_state=LOAD_DATA;
											else if(parity_done)
													next_state=DECODE_ADDRESS;
							LOAD_PARITY: next_state=CHECK_PARITY_ERROR;
							CHECK_PARITY_ERROR: if(fifo_full)
												next_state=FIFO_FULL_STATE;
												else if(!fifo_full)
												next_state=DECODE_ADDRESS;
							default : next_state=DECODE_ADDRESS;
						endcase
				end

			assign busy = (state==LOAD_FIRST_DATA)||(state==WAIT_TILL_EMPTY)||(state==FIFO_FULL_STATE)||(state==LOAD_AFTER_FULL)||(state==LOAD_PARITY)||(state==CHECK_PARITY_ERROR);

			assign detect_add = (state==DECODE_ADDRESS);
			assign ld_state = (state==LOAD_DATA);
			assign laf_state = (state==LOAD_AFTER_FULL);
			assign full_state =(state==FIFO_FULL_STATE);
			assign write_enb_reg = (state==LOAD_DATA)||(state==LOAD_PARITY)||(state==LOAD_AFTER_FULL);
			assign rst_int_reg = (state==CHECK_PARITY_ERROR);
			assign lfd_state = (state==LOAD_FIRST_DATA);
endmodule
