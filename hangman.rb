
$save = false 
require 'pstore'

class Loader
	def initialize
		want_load
	end

	def play
		loop do
			@game.game_loop
			if $save
				save_game
			end
		end
	end

	def want_load
		load = String.new
		until load == "y" || load == "n"
			puts "Would you like to load your game from save? (Y/N)"
			load = gets.chomp.downcase
		end
		if load == "n"
			@game = Game.new
			play
		else
			load_game
		end
	end

	def load_game
		store = PStore.new("storagefile")
		store.transaction do
			@game = store[:game]
		end
		$save = false
		play
	end

	def save_game
		store = PStore.new("storagefile")
		store.transaction do
			store[:game] = @game
		end 
		puts "Your game has been saved!"
		exit
	end
end






class Game
	def initialize
		@letters_guessed = []
		@secret_word = pick_secret_word.upcase.split("")
		@placeholder = spaces
		@wrong_letters = [] 
		welcome
	end 

	# selects and returns the secret word
	def pick_secret_word
		File.read("5desk.txt").lines.select {|word| (4..9).cover?(word.size)}.sample.strip
	end

	# welcomes you to the game
	def welcome
		puts "Welcome to Hangman!\n\n"
		puts "The computer has selected a random secret word for you to guess.\n"
		puts "Be careful - you have 6 incorrect guesses before you hang the man!"
	end 

	# returns an array of blank spaces
	def spaces
		@secret_word.map { " _ " }
	end 

	# enter guess or save turn here
	def enter_guess
		@guess = nil
		until valid_guess?(@guess)
			puts "Please enter your guess (A-Z) now, or type 'save' to save (and quit):"
			@guess = gets.chomp.upcase		
		end
	end

	# validates the guess passed to it
	def valid_guess?(guess)
		guess == 'SAVE' || (('A'..'Z').include?(guess) && (!(@wrong_letters.include?(guess))))
	end 

	# returns true if placeholder == secret_word (thus win)
	def win?
		@placeholder == @secret_word
	end 

	# returns true if lose, because *incorrect* guesses == 6
	def lose?
		@wrong_letters.length == 6 
	end 

	# checks if guess is in secret_word, replaces placeholer _ with letter or wrong letter
	def compare
		if @secret_word.include?(@guess)
			@secret_word.each_index do |x|
				if @secret_word[x] == @guess
					@placeholder[x] = @guess
				end
			end
		elsif @guess == "SAVE"
			$save = true
		elsif
			@wrong_letters << @guess
		end
	end 

	# returns joined array with commas
	def show_wrong_letters
		@wrong_letters.sort.join(", ")
	end

	# returns placerholder joined with spaces
	def show_progress
		@placeholder.join(" ")
	end 

	def game_loop
		puts "wrong letters: #{@wrong_letters.join(" ")}"
		puts "last guess: #{@guess}"
		puts show_progress
		hanged_man
		puts "Wrong letters #{show_wrong_letters}"
		enter_guess
		compare
		if win?
			puts "You win!"
			exit
		elsif lose?
			hanged_man
			puts "You have killed the man!"
			exit
		end
	end

	def hanged_man
		case @wrong_letters.length
			when 0
			puts "\n|----"
			puts "|   |"
			puts "|"
			puts "|"
			puts "|"
			puts "|"
			puts "|"
			when 1
			puts "\n|----"
			puts "|   |"
			puts "|   O"
			puts "|"
			puts "|"
			puts "|"
			puts "|"
			when 2
			puts "\n|----"
			puts "|   |"
			puts "|   O"
			puts "|   U"
			puts "|"
			puts "|"
			puts "|"
			when 3
			puts "\n|----"
			puts "|   |"
			puts "|   O"
			puts "|   U/"
			puts "|"
			puts "|"
			puts "|"
			when 4
			puts "\n|----"
			puts "|   |"
			puts "|   O"
			puts "|  \\U/"
			puts "|"
			puts "|"
			puts "|"
			when 5
			puts "\n|----"
			puts "|   |"
			puts "|   O"
			puts "|  \\U/"
			puts "|  /"
			puts "|"
			puts "|"
			when 6
			puts "\n|----"
			puts "|   |"
			puts "|   O"
			puts "|  \\U/"
			puts "|  / \\"
			puts "|"
			puts "|"
		end 
	end 
end

Loader.new