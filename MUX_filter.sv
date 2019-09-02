`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2019 01:07:00
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
    input logic [3:0] sw,
    output logic [11:0] pix_out
    );
    
    // intenciar filtros aqui abajo
    
    
    
    logic [23:0] in1,in2,in3; //inx: intermedio x
    
    always_comb begin
        if(sw[0]) in1 = dither;
        else in1 = pix_in;
        
        if(sw[1]) in2 = gray;
        else in2 = in1;
        
        if(sw[2]) in3 = scramble;
        else in3 = in2;
        
        if(sw[3]) pix_out = sobel;
        else pix_out = in3;
    end
endmodule
