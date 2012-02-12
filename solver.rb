
def read_file
  file = open("puzzle.txt")
  lines = []
  while line = file.gets
    lines << line
  end
  lines
end

def parse_board(lines)
  board = []
  lines.each { |line| 
    parsed_cells = parse_line(line)
    board << parsed_cells unless parsed_cells.empty?
  }

  if board.length != 9
    puts "Invalid number of rows"
  end

  board
end

def parse_line(line)
  cells = line.scan(/[\d_]+/)

  cells.collect { |cell| 
    if !cell[/\d+/].nil?
      cell.to_i()
    else
      "_"
    end
  }
end

def output_board(board)
  puts "-------------------------"
  board.each { |row|
    puts row.join(' ')
  }
  puts "-------------------------"
end


def get_cell_possibilities(board, row_num, col_num)
  get_row_possibilities(board, row_num) & 
  get_column_possibilities(board, col_num) &
  get_group_possibilities(board, row_num, col_num)
end

def get_array_possibilities(array)
  (1..9).select { |possibility| !array.member?(possibility) }
end

def get_row_possibilities(board, row_num)
  get_array_possibilities(board[row_num])
end

def get_column_possibilities(board, col_num)
  column = get_column(board, col_num)
  get_array_possibilities(column)
end

def get_column(board, col_num)
  result = []
  board.each { |row| result << row[col_num] }
  result
end

def get_groupings(row_num, col_num)
  groupings = [ [0,1,2], [3,4,5], [6,7,8] ]
  row_group = groupings.find { |grouping| grouping.member?(row_num) }
  col_group = groupings.find { |grouping| grouping.member?(col_num) }
  { :row_group => row_group, :col_group => col_group }
end

def get_group_cells(board, row_num, col_num)
  groups = get_groupings(row_num, col_num)
  row_group = groups[:row_group]
  col_group = groups[:col_group]
  group = []

  min_col = col_group[0]
  max_col = col_group[2]
  row_group.each { |row| 
    group.concat(board[row].slice(min_col..max_col))
  }
  group
end

def get_group_possibilities(board, row_num, col_num)
  cells = get_group_cells(board, row_num, col_num)
  get_array_possibilities(cells)
end

def get_first_unfilled_cell(board)
  row_num = 0
  board.each { |row|
    found_index = row.index("_")
    if found_index
      return ({ :row_num => row_num, :col_num => found_index })
    end
    row_num += 1
  }
  
  nil
end

def is_array_invalid(array)
  if array.length < 9
    true
  end
  
  invalid = false
  array.each { |element|
    invalid |= (1 != array.count(element))
  }
  
  invalid
end

def is_board_valid(board)
  invalid = false
  row_num = 0
  board.each { |row|
    invalid |= is_array_invalid(row)
    
    (0..8).each { |col_num|
      invalid |= is_array_invalid(
                                  get_group_cells(board, row_num, col_num))
    }
    row_num += 1
  }
  
  (0..8).each { |num|
    invalid |= is_array_invalid(get_column(board, num))
  }
  
  !invalid
end

# Do a deep clone of the board, built-in clone method
# only does a shallow clone
def clone_board(board)
  Marshal.load(Marshal.dump(board))
end

def solve_board(board)
  unfilled_cell = get_first_unfilled_cell(board)

  if unfilled_cell.nil? && is_board_valid(board)
    return board
  elsif unfilled_cell.nil?
    return nil
  end

  guess_board = clone_board(board)

  unfilled_cell_row = unfilled_cell[:row_num]
  unfilled_cell_col = unfilled_cell[:col_num]

  possibilities = get_cell_possibilities(guess_board,
                                         unfilled_cell_row,
                                         unfilled_cell_col)

  while !possibilities.empty?
    possibility = possibilities.shift
    guess_board[unfilled_cell_row][unfilled_cell_col] = possibility
    result = solve_board(guess_board.clone)

    return result unless result.nil?
  end
end

def count_unfilled_cells(board)
  sum = 0
  board.each { |row| 
    sum += row.count("_")
  }
  sum
end
