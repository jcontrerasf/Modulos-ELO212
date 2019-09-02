`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2019 04:36:38
// Design Name: 
// Module Name: sobel_intento1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sobel_intento1(
    input logic clk, rst,
    input logic [23:0] pix_in,
    output logic [23:0] pix_out
    );
    
    logic save;
    logic [3:0] pix_ant;
    
    always_comb begin
        if (pix_in - pix_ant >= 4'd8) pix_out = 24'd15;
        else pix_out = 24'd0;
    end
    
    always_ff@(posedge clk) begin
        save <= ~save;
    end
    
   banco_de_registro #(.bits(4)) mem(.guardar(save),.clock(clk),.reset(rst),.entrada(pix_in[23:20]),.salida(pix_ant));
endmodule





module banco_de_registro
#(parameter
 bits = 16 )
(
    input logic guardar, clock, reset,
    input logic [bits-1:0] entrada,
    output logic [bits-1:0] salida
    );
    
    logic [bits-1:0] intermedio;
    
   always_comb begin
   
            if(guardar) 
                intermedio = entrada;
             else
                intermedio = salida;
            
   end
        
    always@(negedge clock)
    	if(reset)
    		salida <= 'b0;
    	else
    	   salida <= intermedio; 
    
endmodule
