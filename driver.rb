$LOAD_PATH << File.dirname(__FILE__)

require 'solver'


board_text = read_file
board = parse_board(board_text)

puts "Started solving at: ", Time.new.inspect
result = solve_board(board)
output_board(result)
puts "Finished solving at: ", Time.new.inspect
