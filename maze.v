`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:34:54 11/29/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze(
		input 		                     clk,
		input      [maze_width - 1:0]    starting_col, starting_row, 	// indicii punctului de start
		input  			                  maze_in, 			            // ofera informa?ii despre punctul de coordonate [row, col]
		output reg [maze_width - 1:0]    row, col,	 		            // selecteaza un rând si o coloana din labirint
		output reg			               maze_oe,			            // output enable (activeaza citirea din labirint la rândul ?i coloana date) - semnal sincron	
		output reg			               maze_we, 			            // write enable (activeaza scrierea în labirint la rândul ?i coloana date) - semnal sincron
		output reg			               done);		 	               // ie?irea din labirint a fost gasita; semnalul ramane activ 

//stari
`define initial 0
`define checkDirection 1
`define rightMove 2
`define upMove 3
`define leftMove 4
`define downMove 5
`define stop 6

parameter maze_width = 6;
reg [maze_width - 1:0] current_row, current_col;
reg [1:0] direction; //0-dreapta, 1-sus, 2-stanga, 3-jos
reg [4:0] state = 0, next_state = 0;

always @(posedge clk) begin
	state <= next_state;
end

always @(*) begin
	maze_we = 0;
	maze_oe = 0;
	case(state)	
	
		//
		`initial: begin
			maze_we = 1;
			row = starting_row;
			col = starting_col;
			current_row = starting_row;
			current_col = starting_col;
			direction = 0; //incepem din dreapta
			next_state = `checkDirection;
			done = 0;
		end
		
		//
		`checkDirection: begin

			if (direction == 0) begin
				row = current_row + 1;
				col = current_col;
				next_state = `downMove;
			end else if (direction == 1) begin
				row = current_row;
				col = current_col + 1;
				next_state = `rightMove;
			end else if (direction == 2) begin
				row = current_row - 1;
				col = current_col;
				next_state = `upMove;
			end else if (direction == 3) begin
				row = current_row;
				col = current_col - 1;
				next_state = `leftMove;
			end
			
			maze_oe = 1;
			maze_we = 0;
		end
		
		//
		`rightMove: begin

			if (maze_in == 0) begin
				current_col = current_col + 1;
				direction = 0;
				next_state = `checkDirection;
				maze_we = 1;
				if (col == 0 || col == 63 || row == 0 || row == 63) begin
					maze_we = 1;
					next_state = `stop;
				end
			end else if (maze_in == 1) begin
				row = current_row - 1;
				col = current_col;
				next_state = `upMove;
				maze_oe = 1; 
			end
		end
		
		//
		`upMove: begin

			if (maze_in == 0) begin
				current_row = current_row - 1;
				direction = 1;
				next_state = `checkDirection;
				maze_we = 1;
				if (col == 0 || col == 63 || row == 0 || row == 63) begin
					maze_we = 1;
					next_state = `stop;
				end
			end else if (maze_in == 1) begin
				row = current_row;
				col = current_col - 1;
				next_state = `leftMove;
				maze_oe = 1;
			end
		end
		
		//
		`leftMove: begin

			if (maze_in == 0) begin
				current_col = current_col - 1;
				direction = 2;
				next_state = `checkDirection;
				maze_we = 1;
				if (col == 0 || col == 63 || row == 0 || row == 63) begin
					maze_we = 1;
					next_state = `stop;
				end
			end else if (maze_in == 1) begin
				row = current_row + 1;
				col = current_col;
				next_state = `downMove;
				maze_oe = 1;
			end
		end
		
		//
		`downMove: begin
		
			if (maze_in == 0) begin
				current_row = current_row + 1;
				direction = 3;
				maze_we = 1;
				next_state = `checkDirection;
				if (col == 0 || col == 63 || row == 0 || row == 63) begin
					maze_we = 1;
					next_state = `stop;
				end
			end else if (maze_in == 1) begin
				row = current_row;
				col = current_col + 1;
				next_state = `rightMove;
				maze_oe = 1;
			end
		end
		
		//
		`stop: begin
			done = 1;
		end

		
	endcase
end

endmodule
