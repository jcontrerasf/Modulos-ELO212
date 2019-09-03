`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2019 01:00:35
// Design Name: 
// Module Name: MUX_filter
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


module MUX_filter(
    input logic [23:0] pix_in,
    input logic [15:0] sw,
    input logic reset,clock,
    input logic hc,vc,
    output logic [11:0] pix_out
    );
    
    // intenciar filtros aqui abajo
    
    //NO
    
    logic [23:0] in1,in2,in3,dither,gray,scramble,sobel, in4;
    assign pix_out = {in4[23:20],in4[15:12],in4[7:4]};
    
    always_comb begin
        if(sw[0]) in1 = dither;
        else in1 = pix_in;
        
        if(sw[1]) in2 = gray;
        else in2 = in1;
        
        if(sw[2]) in3 = scramble;
        else in3 = in2;
        
        if(sw[3]) in4 = sobel;
        else in4 = in3;
    end
    
 grayscale blanconegro(.pix_in(in1),.pix_out(gray));
 
 color_scra colores(.SWR(sw[15:14]),.SWG(sw[13:12]),.SWB(sw[11:10])
 ,.entrada(in2),.salida(scramble));
 
 dithering paleta(.hc(hc),.vc(vc),.entrada(pix_in),.salida(dither),.SW(1'b1));
 
 sobel_intento1 sobame_por_favor_tengo_calocha(.rst(reset),.clk(clock),.pix_in(in3),.pix_out(sobel)); 
 
endmodule
