class Board
  attr_reader :raw_board

  def initialize(raw_board)
    @raw_board = raw_board
  end

  def row(number)
    raw_board[number]
  end

  def column(number)
    raw_board.map { |row| row[number] }
  end

  def square(row, column)
    starting_x = row / 3 * 3
    starting_y = column / 3 * 3

    numbers_in_square = []

    3.times do |i|
      3.times do |j|
        numbers_in_square << raw_board[starting_x + i][starting_y + j]
      end
    end

    numbers_in_square
  end

  def set_new_value(row, column, value)
    raw_board[row][column] = value
  end
end

class Solver
  NUMBERS = [1, 2, 3, 4, 5, 6, 7, 8, 9].freeze

  def initialize(board)
    @board = board
  end

  def solved?
    empty_fields.empty?
  end

  def first_empty_field
    empty_fields.first
  end

  def possible_values_for(row, column)
    allowed_in(row, column)
  end

  private

  attr_reader :board

  def empty_fields
    fields = []
    board.raw_board.each_with_index do |row, row_index|
      row.each_with_index do |field, column_index|
        fields << [row_index, column_index] if field.zero?
      end
    end
    fields
  end

  def allowed_in(row, column)
    allowed_in_row(row) & allowed_in_column(column) & allowed_in_square(row, column)
  end

  def allowed_in_row(row)
    NUMBERS - board.row(row)
  end

  def allowed_in_column(column)
    NUMBERS - board.column(column)
  end

  def allowed_in_square(row, column)
    NUMBERS - board.square(row, column)
  end
end

class Sudoku
  def initialize(board)
    @board = board
    @solver = Solver.new(board)
  end

  def solve
    return board if solver.solved?

    row, column = solver.first_empty_field

    solver.possible_values_for(row, column).each do |possible_value|
      board.set_new_value(row, column, possible_value)
      return board if solve
    end

    board.set_new_value(row, column, 0)
    false
  end

  private

  attr_reader :board, :solver
end

RSpec.describe Sudoku do
  subject { described_class.new(Board.new(raw_board)) }

  let(:raw_board) do
    [
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 3, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9],
    ]
  end

  it 'solves sudoku' do
    expected_raw_board = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ]

    expect(subject.solve.raw_board).to eq expected_raw_board
  end
end
