module main(
	input CLK100MHZ,
	input [15:0]SW,
	input CPU_RESETN, UART_TXD_IN,

	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
	);
	
	
	logic CLK82MHZ;
	logic rst = 0;
	logic hw_rst = ~CPU_RESETN;
	logic listo_in; //1 cuando un pixel entero está listo
	logic [17:0] addrA, addrB; //dirección de la entrada A de la memoria
	logic [23:0] pixeles_in;
	logic [23:0] pixeles_out;
	
	clk_wiz_0 inst(
		// Clock out ports  
		.clk_out1(CLK82MHZ),
		// Status and control signals               
		.reset(1'b0), 
		//.locked(locked),
		// Clock in ports
		.clk_in1(CLK100MHZ)
		);
		
		                                                              //DEBE SER 100MHZ
		uart_rx_main UART(.uart_in_cable(UART_TXD_IN),.reset(hw_rst),.clock(CLK100MHZ),.salida(pixeles_in),.listo(listo_in));
		
		BRAM bram(.addra(addrA),
		.clka(CLK100MHZ), //reloj de entrada (no se si es 100, listo_in, o baud)
		.dina(pixeles_in), // entrada de datos A
		.ena(1'b1), //enableA (revisar)
		.wea(listo_in), //write enable (no se que poner) [0:0] ???
		.addrb(addrB), //direccion B [17:0]
		.clkb(CLK82MHZ),
		.doutb(pixeles_out), //salida de datos B [23:0]
		.enb(1'b1)); //enableB (revisar)
		
		
		//************ CONTADOR **************
		always_ff@(posedge CLK100MHZ) begin
		  if(hw_rst) addrA <= 'b0;
		  else if(listo_in) addrA <= addrA + 1;
		  else addrA <= addrA;
		end
	



	/************************* VGA ********************/
	logic [2:0] op;
	logic [2:0] pos_x;
	logic [1:0] pos_y;
	logic [15:0] op1, op2;

	screen screen(
		.clk_vga(CLK82MHZ),
		.rst(rst),
		.pos_x(pos_x),
		.pos_y(pos_y),
		.pixeles_out(pixeles_out),
		.addrB(addrB),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B));

endmodule



module screen(
	input clk_vga,
	input rst,
	input [2:0]pos_x,
	input [1:0]pos_y,
	input [23:0] pixeles_out, //viene del puerto B de la BRAM
	
	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B,
	output logic [17:0] addrB
	);
	
	
	localparam ALTO_IMG = 384;
	localparam ANCHO_IMG = 512;
	
	localparam CUADRILLA_XI = 		0;
	localparam CUADRILLA_XF = 		CUADRILLA_XI + ANCHO_IMG;
	
	localparam CUADRILLA_YI = 		0;
	localparam CUADRILLA_YF = 		CUADRILLA_YI + ALTO_IMG;
	
	
	logic [10:0]vc_visible,hc_visible;
	
	// MODIFICAR ESTO PARA HACER LLAMADO POR NOMBRE DE PUERTO, NO POR ORDEN!!!!!
	driver_vga_1024x768 m_driver(clk_vga, VGA_HS, VGA_VS, hc_visible, vc_visible);
	/*************************** VGA DISPLAY ************************/
		
	logic [10:0]hc_template, vc_template;
	logic [2:0]matrix_x;
	logic [1:0]matrix_y;
	
	logic [11:0]VGA_COLOR;
	
	logic text_sqrt_fg;
	logic text_sqrt_bg;

	logic [1:0]generic_fg;
	logic [1:0]generic_bg;	
	
	
	
	
	localparam COLOR_BLUE 		= 12'h00F;
	localparam COLOR_YELLOW 	= 12'hFF0;
	localparam COLOR_RED		= 12'hF00;
	localparam COLOR_BLACK		= 12'h000;
	localparam COLOR_WHITE		= 12'hFFF;
	localparam COLOR_CYAN		= 12'h0FF;
	
	always_ff@(posedge clk_vga) begin
	   if(rst) addrB <= 'b0;
	   else if((hc_visible != 0) && (vc_visible != 0) && (hc_visible > CUADRILLA_XI) && (hc_visible <= CUADRILLA_XF) && (vc_visible > CUADRILLA_YI) && (vc_visible <= CUADRILLA_YF))
	   addrB <= (513*vc_visible) + hc_visible;
	end
	
	always@(*)
		if((hc_visible != 0) && (vc_visible != 0))
		begin
			if((hc_visible > CUADRILLA_XI) && (hc_visible <= CUADRILLA_XF) && (vc_visible > CUADRILLA_YI) && (vc_visible <= CUADRILLA_YF))
				VGA_COLOR = {pixeles_out[23:20],pixeles_out[15:12],pixeles_out[7:4]};
			else
				VGA_COLOR = COLOR_BLUE;//el fondo de la pantalla
		end
		else
			VGA_COLOR = COLOR_BLACK;//esto es necesario para no poner en riesgo la pantalla.

	assign {VGA_R, VGA_G, VGA_B} = VGA_COLOR;
endmodule

