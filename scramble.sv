`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2018 02:36:31 AM
// Design Name: 
// Module Name: color_scra
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


module color_scra(
    input logic [23:0] entrada,
    input logic [1:0] SWR,SWG,SWB,
    output logic [23:0] salida
    );
    logic [7:0] CR,CG,CB;
    logic [7:0] SR,SG,SB;
    
    assign {CR,CG,CB} = entrada;
    assign salida = {SR,SG,SB};
    
    always_comb begin
        case(SWR)
        2'd0: SR=CR;
        2'd1: SR=CG;
        2'd2: SR=CB;
        2'd3: SR=8'd0;
        endcase
        end
     
     always_comb begin
        case(SWG)
        2'd0: SG=CR;
        2'd1: SG=CG;
        2'd2: SG=CB;
        2'd3: SG=8'd0;
        endcase
        end
                
     always_comb begin
        case(SWB)
        2'd0: SB=CR;
        2'd1: SB=CG;
        2'd2: SB=CB;
        2'd3: SB=8'd0;
        endcase
        end           
                
        
endmodule
