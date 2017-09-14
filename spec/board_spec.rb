require "board"
describe Board do
  before(:each) do
    @gameboard = Board.new
  end
  it "should respond to :build_board" do
    expect(@gameboard).to respond_to(:build_board)
    expect(@gameboard).to respond_to(:populate_board)
  end
  context ":build_board" do
    before(:each) do
      @gameboard.build_board
    end
    it "should create 64 squares" do
      expect(@gameboard.data.keys.count).to eql(64)
    end
    it "should assign coordinates as keys" do
      expect(@gameboard.data.keys.include?([1,1])).to eql(true)
      expect(@gameboard.data.keys.include?([2,2])).to eql(true)
      expect(@gameboard.data.keys.include?([3,3])).to eql(true)
      expect(@gameboard.data.keys.include?([4,4])).to eql(true)
      expect(@gameboard.data.keys.include?([5,5])).to eql(true)
      expect(@gameboard.data.keys.include?([6,6])).to eql(true)
      expect(@gameboard.data.keys.include?([7,7])).to eql(true)
      expect(@gameboard.data.keys.include?([8,8])).to eql(true)
    end
    it "should associate coordinates with string names" do
      expect(@gameboard.data[[1,1]][:proper_name]).to eql("a1")
      expect(@gameboard.data[[2,2]][:proper_name]).to eql("b2")
      expect(@gameboard.data[[3,3]][:proper_name]).to eql("c3")
      expect(@gameboard.data[[4,4]][:proper_name]).to eql("d4")
      expect(@gameboard.data[[5,5]][:proper_name]).to eql("e5")
      expect(@gameboard.data[[6,6]][:proper_name]).to eql("f6")
      expect(@gameboard.data[[7,7]][:proper_name]).to eql("g7")
      expect(@gameboard.data[[8,8]][:proper_name]).to eql("h8")
    end


  end

  context ":populate_board" do
    before(:each) do
      @gameboard.build_board
      @gameboard.populate_board
    end
    it "should place a white rook on a1" do
      expect(@gameboard.data[[1,1]][:occupant].traits[:type]).to eql(:rook)
      expect(@gameboard.data[[1,1]][:occupant].traits[:color]).to eql(:white)
    end
    it "should place a black rook on h8" do
      expect(@gameboard.data[[8,8]][:occupant].traits[:type]).to eql(:rook)
      expect(@gameboard.data[[8,8]][:occupant].traits[:color]).to eql(:black)
    end
    it "should place a white knight on b1" do
      expect(@gameboard.data[[2,1]][:occupant].traits[:type]).to eql(:knight)
      expect(@gameboard.data[[2,1]][:occupant].traits[:color]).to eql(:white)
    end
    it "should place a black knight on g8" do
      expect(@gameboard.data[[7,8]][:occupant].traits[:type]).to eql(:knight)
      expect(@gameboard.data[[7,8]][:occupant].traits[:color]).to eql(:black)
    end
    it "should place a white bishop on b1" do
      expect(@gameboard.data[[3,1]][:occupant].traits[:type]).to eql(:bishop)
      expect(@gameboard.data[[3,1]][:occupant].traits[:color]).to eql(:white)
    end
    it "should place a black bishop on g8" do
      expect(@gameboard.data[[6,8]][:occupant].traits[:type]).to eql(:bishop)
      expect(@gameboard.data[[6,8]][:occupant].traits[:color]).to eql(:black)
    end
    it "should place a white queen on d1" do
      expect(@gameboard.data[[4,1]][:occupant].traits[:type]).to eql(:queen)
      expect(@gameboard.data[[4,1]][:occupant].traits[:color]).to eql(:white)
    end
    it "should place a black king on e8" do
      expect(@gameboard.data[[5,8]][:occupant].traits[:type]).to eql(:king)
      expect(@gameboard.data[[5,8]][:occupant].traits[:color]).to eql(:black)
    end

    it "should place 16 pawns" do
      placed_pieces = @gameboard.data.select{|k,v| v.include?(:occupant)}
      expect(placed_pieces.select{|k,v| v[:occupant].traits[:type]==:pawn}.count).to eql(16)
    end
  end
end
