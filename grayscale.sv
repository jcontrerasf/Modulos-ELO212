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
    
    logic [7:0] decB,decG,decR,prom;
    assign decB = ((pix_in[7:0] >> 3) + (pix_in[7:0] >> 4)) >> 1;
    assign decR = ((pix_in[23:16] >> 3) + (pix_in[23:16] >> 4)) >> 1;
    assign decG = ((pix_in[15:8] >> 3) + (pix_in[15:8] >> 4)) >> 1;
    assign prom = decR*3+decG*6+decB;
    
    assign pix_out = {prom[7:0],prom[7:0],prom[7:0]};
   
    
endmodule
