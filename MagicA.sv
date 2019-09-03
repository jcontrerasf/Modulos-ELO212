`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2018 09:16:38 PM
// Design Name: 
// Module Name: MagicA
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


module MagicA(
    input logic clk,ready,
    input logic [7:0] color,
    output logic [23:0] colores,
    output logic enable,
    output logic [2:0] estado,
    output logic [17:0] direccion
    );
    
    enum logic [2:0] {EC1,GC1,EC2,GC2,EC3,GC3,ble,adir} state, nextstate;
    logic [7:0] colorR,colorG,colorB,colorRnext,colorGnext,colorBnext;
    logic [17:0] dir;
    
    always_ff @(posedge clk) begin
        state <= nextstate;
        colorR <= colorRnext;
        colorG <= colorGnext;
        colorB <= colorBnext;
        if (state==adir) begin
            dir <= dir + 18'd1;
            enable <= 1'd0;
            end
        else if (state==ble) begin
            dir <= dir;
            enable <= 1'd1;
            end
        else if (dir==18'd197632) begin
            dir <= 18'd0;
            enable <= 1'd0;
            end   
        else begin
            dir <= dir;
            enable <= 1'd0;
            end   
        end
        
        
    always_comb begin
        nextstate = state;
        colorRnext =colorR;
        colorGnext = colorG;
        colorBnext = colorB;
        case(state)
            EC1:  if(ready==1'b1) 
                        nextstate = GC1;
                        
            GC1: begin
                    colorRnext = color;
                    nextstate = EC2;
                    end
            
            EC2: if(ready==1'b1) 
                        nextstate = GC2;
                        
            GC2: begin
                    colorGnext = color;
                    nextstate = EC3;
                    end
            
            EC3: if(ready==1'b1) 
                        nextstate = GC3; 
            
            GC3: begin
                    colorBnext = color;
                    nextstate = ble;
                    end
            ble: nextstate = adir;
                    
            adir: nextstate = EC1;        
                                            
        endcase
        end
        
        assign colores=({colorR,colorG,colorB});
        assign estado=state;
        assign direccion=dir;
        
        endmodule
