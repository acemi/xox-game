import std.stdio;
import std.conv;
import std.format;
import std.string;
import std.range;
import std.algorithm;
import std.random;

T input(T, string conditions = "true")(in string msg, in string fmt, 
	in string invalidInputErrorMessage = "Invalid input. Please try again.",
	in string conditionErrorMessage = "Your data doesn't match the conditions.")
{
	stdout.writeln(msg);
	while(true) {
		try {
			stdout.write(">> ");
			string readLine = chomp(readln());
			T toReturn;
			formattedRead(readLine, fmt, &toReturn);
			if(mixin(conditions)) {
				return toReturn;
			} else {
				throw new Exception(conditionErrorMessage);
			}
		} catch (std.conv.ConvException e) {
			stderr.writeln("[" ~ invalidInputErrorMessage ~ "]");
		} catch (Exception e) {
			stderr.writeln("[" ~ e.msg ~ "]");
		}
	}
}

enum MARK {
	EMPTY = 0, X = 1, O = 2
}

struct Location {
	size_t row;
	size_t col;
	this(size_t newRow, size_t newCol)
	{
		this.row = newRow;
		this.col = newCol;
	}
	bool isValid() @property
	{
		return row >= 0 && row < 3 && col >= 0 && col < 3;
	}
}

class Board {
	MARK[3][3] tiles;
	override string toString() const
	{
		string boardString;
		foreach(MARK[3] row; tiles) {
			foreach(MARK column; row){
				final switch(column){
					case MARK.EMPTY: boardString ~= "- "; break;
					case MARK.X: boardString ~= "X "; break;
					case MARK.O: boardString ~= "O "; break;
				}
			}
			boardString ~= "\n";
		}
		return boardString;
	}

	void put(size_t row, size_t col, MARK mark) 
	{
		this.tiles[row][col] = mark;
	}

	void clean() 
	{
		this.tiles.clear();
	}

	bool check(size_t row, size_t col, MARK mark) const
	{
		immutable(MARK[]) threeInARow = [mark, mark, mark];

		MARK[] h = [this.tiles[row][0], this.tiles[row][1], this.tiles[row][2]];
		MARK[] v = [this.tiles[0][col], this.tiles[1][col], this.tiles[2][col]];
		MARK[] d1 = [this.tiles[0][0], this.tiles[1][1], this.tiles[2][2]]; 
		MARK[] d2 = [this.tiles[0][2], this.tiles[1][1], this.tiles[2][0]];

		if(h == threeInARow || v == threeInARow || d1 == threeInARow || d2 == threeInARow) {
			return true;
		} else {
			return false;
		}
	}
}

class Game {
	struct Player {
		uint score = 0;
		string name;
		MARK mark;
		bool isAI;
	}

	Player player1;
	Player player2;
	protected Board board = new Board();
	uint maxScore;

	bool goesOn () @property
	{
		// Game goes on while no one reaches the maximum score
		return player1.score != this.maxScore && player2.score != this.maxScore;
	}

	this(bool isAI) 
	{
		if(isAI) {
			this.player2.isAI = true;
		}
		// Ask for names
		this.player1.name = input!(string, "toReturn.length < 25")
								("Who are you, Player 1?","%s","What?", "Don't you think that this is a bit too long?");
		this.player1.mark = MARK.X;
		this.player2.name = (this.player2.isAI) ? "Computer" : 
							input!(string, "toReturn.length < 25")
								("Who are you, Player 2?","%s","What?", "Don't you think that this is a bit too long?");
		this.player2.mark = MARK.O;
		this.maxScore = input!(uint, "toReturn > 0")
							("Maximum score?","%s","Please type a number.", "It should be bigger than zero!");
	}

	void showBoard() const
	{
		stdout.writeln(this.board);
	}

	void showScores() const
	{
		writefln("%s: %s\n%s: %s",
			this.player1.name, this.player1.score,
			this.player2.name, this.player2.score);
	}

	bool checkBoard(size_t row, size_t col, Player* whoseTurn) const
	{
		if(this.board.check(row, col, whoseTurn.mark)) {
			this.showBoard();
			whoseTurn.score++;
			return true;
		} else {
			return false;
		}
	}

	void cleanBoard()
	{
		this.board.clean();
	}

	void putInBoard(size_t row, size_t col, MARK mark)
	{
		this.board.put(row,col,mark);
	}

	Location askPlayerForLocation(Player* whoseTurn)
	{
		this.showBoard();
		writefln("%s's turn",whoseTurn.name);
		while(true) {
		try {
			stdout.write(">> ");
			string readLine = chomp(readln());
			Location toReturn;
			formattedRead(readLine, " %s %s", &toReturn.row, &toReturn.col);
			toReturn.row--; toReturn.col--;
			if(toReturn.isValid) {
				if(this.board.tiles[toReturn.row][toReturn.col] == MARK.EMPTY) {
					return toReturn;
				} else {
					throw new Exception("[Already occupied.]");
				}
			} else {
				throw new Exception("[Locations are invalid.]");
			}
		} catch (std.conv.ConvException e) {
			stderr.writeln("[Please enter locations as ROW COLUMN]");
		} catch (Exception e) {
			stderr.writeln(e.msg);
		}
	}
	}

	Location askAIForLocation(Player* whoseTurn)
	{
		writeln("Computer's turn");
		size_t computerRow;
		size_t computerCol;
		uint random = uniform(1,101);
		if(random < 80) {
			// AI IS NOT READY YET
		}
		return Location(computerRow,computerCol);
	}
}

int main(string args[])
{
	bool mainLoop = true;

	while(mainLoop) {
		
		stdout.writeln("=============");
		stdout.writeln("THE XOX GAME");
		stdout.writeln("=============");
		stdout.writeln("(1) SINGLE PLAYER");
		stdout.writeln("(2) TWO PLAYERS");
		stdout.writeln("(3) QUIT");

		int menuInput = input!(int, "toReturn > 0 && toReturn < 4")
						("Please make a choice.", " %s", "Invalid selection. Please try again.", "Invalid selection. Please try again.");
		bool isAI_L;
		final switch(menuInput) {
			case 1: isAI_L = true; break;
			case 2: isAI_L = false; break;
			case 3: return 0; break; // No need for break, actually.
		}
		Game game = new Game(isAI_L); // Collect the data
		game.Player* whoseTurn;
		writeln("ALRIGHT! Let the game begin!\n=============");
		// GAME LOOP
		int round = 0;
		do {
			// ROUND LOOP
			game.showScores();
			while(true) {
				round++;
				whoseTurn = (round % 2) ? &game.player1 : &game.player2; // If round is even, it's Player2's turn
				Location locationInput = (!whoseTurn.isAI) ? game.askPlayerForLocation(whoseTurn) : game.askAIForLocation(whoseTurn);
				game.putInBoard(locationInput.row, locationInput.col, whoseTurn.mark);
				if(game.checkBoard(locationInput.row, locationInput.col, whoseTurn)){
					writefln("%s scores!", whoseTurn.name);
					game.cleanBoard();
					break; // Check if the game still goesOn
				} else if(round % 9 == 0) {
					writeln("Tie.");
					game.showBoard();
					game.cleanBoard();
					break;
				}
			}
			stdout.writeln("==========");
		} while(game.goesOn);
		game.showScores();
		writeln("* * * * ", whoseTurn.name, " WINS!", " * * * *");

	}
	return 0;
}