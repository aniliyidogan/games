require "json"

class Hangman
  def initialize(args = {})
    @finish = false
    @level = args[:level] ||= "easy"
    @category = args[:category] ||= "computer"
    set_level
    json_parse
    set_random_word
    @letters = @word.length
    @word_arr = @word.split("")
    @new_word = @word.gsub(/[a-z]/, "_").split("")
  end

  def start
    loop do
      puts game_info
      if @word_arr != @new_word && @life > 0
        print "\n=> "
        c = gets.chomp.downcase
        c.split("").map { |d| process(d) }
      elsif @word_arr == @new_word && @life > 0
        finish
        puts win_message
      else
        finish
        puts fail_message
      end
      break if finish?
    end
  end

  private

  def json_parse
    @json = File.open("words.json") do |j|
              JSON.parse(j.read)
            end
  end

  def set_level
    @life = case @level.downcase
              when "easy"
                12
              when "normal"
                9
              when "hard"
                6
              end
  end

  def set_random_word
    json = @json[@category]
    category_length = json.length
    rand = Random.new
    rand = rand(0..category_length)
    @word = json[rand].downcase
  end

  def process(d)
    if @word_arr.include?(d)
      find_and_set_index(d)
      set_new_word_with_index(d)
    else
      life_decrease unless d == " " 
    end
  end

  def find_and_set_index(d)
    @index = @word_arr
              .each_with_index
              .select { |char, i| char == d }
              .map { |g| g[1] }
  end

  def set_new_word_with_index(d)
    @index.map { |i| @new_word[i] = d }
  end

  def life_decrease
    @life -= 1
  end

  def finish
    @finish = true
  end

  def finish?
    @finish
  end

  def letters
    "#{@letters} letters"
  end

  def life
    if @life > 1
      ". #{@life} lives"
    elsif @life == 1 
      ". #{@life} life"
    end
  end

  def game_info
    "| #{@new_word.join(" ")} | #{letters} #{life}"
  end

  def win_message
    "\nCongratulations! :) #{correct_word}"
  end

  def fail_message
    "\nUnfortunately! :( #{correct_word}"
  end

  def correct_word
    "Correct word: #{@word}"
  end
end

hangman = Hangman.new
hangman.start