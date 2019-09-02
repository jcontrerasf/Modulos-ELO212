`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: caca ceca landia
// Engineer: 
// 
// Create Date: 01.09.2019 19:04:04
// Design Name: 
// Module Name: grayscale
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


module grayscale(
    input logic [23:0] pix_in,
    output logic [23:0] pix_out
    );
    
    logic [7:0] total,int1,int2,int3,prom;
    assign total = pix_in[23:16]+pix_in[15:8]+pix_in[7:0];
    assign int1 = total >> 1;
    assign int2 = total >> 2;
    assign int3 = int1 + int2;
    assign prom = int3 >> 1;
    
    assign pix_out = {prom,prom,prom};
   
    
endmodule
