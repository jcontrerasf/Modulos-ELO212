//Modulo que agrupa todo lo necesario para la UART


module uart_rx_main(
    input logic uart_in_cable, reset, //reset con logica positiva
    input logic clock, //reloj de 100MHZ     IMPORTANTE!!!
    output logic [23:0] salida,
    output logic listo,
    output logic [17:0] direccion
);


    logic reloj, baud8;
    logic [7:0] out;
    
    reg rx_ready;
    reg rx_ready_sync;
	wire rx_ready_pre;


//uart_rx_ctrl ctrl(.clock(clock),.reset(~reset),.rx_ready(rx_ready),.rx_data(out),.salida(salida),.listo(listo));

MagicA MagicA(.clk(clock),.ready(rx_ready),.color(out),.colores(salida),.enable(listo),.direccion(direccion)); 

uart_baud_tick_gen #(
		.CLK_FREQUENCY(100000000),
		.BAUD_RATE(115200),
		.OVERSAMPLING(8)
	) baud8_tick_blk (
		.clk(clock),
		.enable(1'b1),
		.tick(baud8)
	);
	
	uart_rx uart_rx_blk (
		.clk(clock),
		.reset(reset),
		.baud8_tick(baud8),
		.rx(uart_in_cable),
		.rx_data(out),
		.rx_ready(rx_ready_pre)
	);

	always @(posedge clock) begin
		rx_ready_sync <= rx_ready_pre;
		rx_ready <= ~rx_ready_sync & rx_ready_pre;
	end
	
	
endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Julius Constreiras Diuca AKA: el chupa
// 
// Create Date: 28.08.2019 00:00:00
// Module Name: uart_rx_ctrl
// Description: Maquina de estados que se encarga de recibir los pixeles en
// la secuencia correcta.
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx_ctrl
(
	input logic clock, reset, rx_ready,
	input logic [7:0] rx_data,
	output logic [23:0] salida, //pixel completo
	output logic listo //pixel completo recibido ok
	);

 //Declarations:------------------------------
 
 logic [7:0] rojo, verde, azul;
 logic [7:0] nextrojo, nextverde, nextazul;

 //FSM states type:
 enum logic [2:0] {Start, Wait_RED, Store_RED, Wait_GREEN, Store_GREEN, Wait_BLUE, Store_BLUE, Save_pixel} state, next_state;

 //Statements:--------------------------------

 //FSM state register:
always@(posedge clock or posedge reset) begin
        rojo <= nextrojo;
        verde <= nextverde;
        azul <= nextazul;
    	if(reset)
    		state <= Start;
    	else
    		state <= next_state;		
 end

 //FSM combinational logic:
 always_comb begin
 
 next_state = state;
 nextrojo = rojo;
 nextverde = verde;
 nextazul = azul;
 listo = 1'b0;
 
 salida = {rojo,verde,azul};

	case (state)
	   Start: begin
//	       nextrojo = 8'b0;
//	       nextverde = 8'b0;
//	       nextazul = 8'b0;
	       next_state = Wait_RED;
	   end
		Wait_RED: begin
            if(rx_ready) begin
               next_state = Store_RED;
               end
		end
 
		Store_RED: begin
		  nextrojo = rx_data;
		  next_state = Wait_GREEN;
		  
		end
 
		Wait_GREEN: begin
			if(rx_ready) begin
	           next_state = Store_GREEN;
	           end
		end
		
		Store_GREEN: begin
		  nextverde = rx_data;
		  next_state = Wait_BLUE;
		  
		end
		
		Wait_BLUE: begin
		  if(rx_ready)
		      next_state = Store_BLUE;
		end
		
		Store_BLUE: begin
		  nextazul = rx_data;
		  next_state = Save_pixel;
		  
		end
		Save_pixel: begin
		  listo = 1'b1;
		  next_state = Wait_RED;
		  
		end
		
		
		
	endcase
end
 endmodule


/*
 * uart_baud_tick_gen.v
 * 2017/02/01 - Felipe Veas <felipe.veasv at usm.cl>
 *
 * Baud clock generator for UART, original code from:
 * http://fpga4fun.com/SerialInterface.html
 */

`timescale 1ns / 1ps

module uart_baud_tick_gen
#(
	parameter CLK_FREQUENCY = 25000000,
	parameter BAUD_RATE = 115200,
	parameter OVERSAMPLING = 1
)(
	input clk,
	input enable,
	output tick
);

	function integer clog2;
		input integer value;
		begin
			value = value - 1;
			for (clog2 = 0; value > 0; clog2 = clog2 + 1)
				value = value >> 1;
		end
	endfunction

	localparam ACC_WIDTH = clog2(CLK_FREQUENCY / BAUD_RATE) + 8;
	localparam SHIFT_LIMITER = clog2(BAUD_RATE * OVERSAMPLING >> (31 - ACC_WIDTH));
	localparam INCREMENT =
			((BAUD_RATE * OVERSAMPLING << (ACC_WIDTH - SHIFT_LIMITER)) +
			(CLK_FREQUENCY >> (SHIFT_LIMITER + 1))) / (CLK_FREQUENCY >> SHIFT_LIMITER);

	(* keep = "true" *)
	reg [ACC_WIDTH:0] acc = 0;

	always @(posedge clk)
		if (enable)
			acc <= acc[ACC_WIDTH-1:0] + INCREMENT[ACC_WIDTH:0];
		else
			acc <= INCREMENT[ACC_WIDTH:0];

	assign tick = acc[ACC_WIDTH];

endmodule


/*
 * uart_rx.v
 * 2017/02/01 - Felipe Veas <felipe.veasv at usm.cl>
 *
 * Asynchronous Receiver.
 */

`timescale 1ns / 1ps

module uart_rx
(
	input clk,
	input reset,
	input baud8_tick,
	input rx,
	output reg [7:0] rx_data,
	output reg rx_ready
);

	localparam RX_IDLE  = 'b000;
	localparam RX_START = 'b001;
	localparam RX_RECV  = 'b010;
	localparam RX_STOP  = 'b011;
	localparam RX_READY = 'b100;

	/* Clock synchronized rx input */
	wire rx_bit;
	data_sync rx_sync_inst (
		.clk(clk),
		.in(rx),
		.stable_out(rx_bit)
	);

	/* Bit spacing counter (oversampling) */
	reg [2:0] spacing_counter = 'd0, spacing_counter_next;
	wire next_bit;
	assign next_bit = (spacing_counter == 'd4);

	/* Finite-state machine */
	reg [2:0] state = RX_IDLE, state_next;
	reg [2:0] bit_counter = 'd0, bit_counter_next;
	reg [7:0] rx_data_next;

	always @(*) begin
		state_next = state;

		case (state)
		RX_IDLE:
			if (rx_bit == 1'b0)
				state_next = RX_START;
		RX_START: begin
			if (next_bit) begin
				if (rx_bit == 1'b0) // Start bit must be a 0
					state_next = RX_RECV;
				else
					state_next = RX_IDLE;
			end
		end
		RX_RECV:
			if (next_bit && bit_counter == 'd7)
				state_next = RX_STOP;
		RX_STOP:
			if (next_bit)
				state_next = RX_READY;
		RX_READY:
			state_next = RX_IDLE;
		default:
			state_next = RX_IDLE;
		endcase
	end

	always @(*) begin
		bit_counter_next = bit_counter;
		spacing_counter_next = spacing_counter + 'd1;
		rx_ready = 1'b0;
		rx_data_next = rx_data;

		case (state)
		RX_IDLE: begin
			bit_counter_next = 'd0;
			spacing_counter_next = 'd0;
		end
		RX_RECV: begin
			if (next_bit) begin
				bit_counter_next = bit_counter + 'd1;
				rx_data_next = {rx_bit, rx_data[7:1]};
			end
		end
		RX_READY:
			rx_ready = 1'b1;
		endcase
	end

	always @(posedge clk) begin
		if (reset) begin
			spacing_counter <= 'd0;
			bit_counter <= 'd0;
			state <= RX_IDLE;
			rx_data <= 'd0;
		end else if (baud8_tick) begin
			spacing_counter <= spacing_counter_next;
			bit_counter <= bit_counter_next;
			state <= state_next;
			rx_data <= rx_data_next;
		end
	end

endmodule

/*
 * data_sync.v
 * 2017/05/13 - Felipe Veas <felipe.veasv at usm.cl>
 *
 * This module synchronizes the input with respect the clock signal
 * and filters short spikes on the input line.
 */

`timescale 1ns / 1ps

module data_sync
(
	input clk,
	input in,
	output reg stable_out
);

	/* Clock synchronized input */
	reg [1:0] in_sync_sr;
	wire in_sync = in_sync_sr[0];

	always @(posedge clk)
		in_sync_sr <= {in, in_sync_sr[1]};

	/* Filter out short spikes on the input line */
	reg [1:0] sync_counter = 'b11, sync_counter_next;
	reg stable_out_next;

	always @(*) begin
		if (in_sync == 1'b1 && sync_counter != 2'b11)
			sync_counter_next = sync_counter + 'd1;
		else if (in_sync == 1'b0 && sync_counter != 2'b00)
			sync_counter_next = sync_counter - 'd1;
		else
			sync_counter_next = sync_counter;
	end

	always @(*) begin
		case (sync_counter)
		2'b00:
			stable_out_next = 1'b0;
		2'b11:
			stable_out_next = 1'b1;
		default:
			/* Keep the previous value if the counter is not on its boundaries */
			stable_out_next = stable_out;
		endcase
	end

	always @(posedge clk) begin
		stable_out <= stable_out_next;
		sync_counter <= sync_counter_next;
	end

endmodule