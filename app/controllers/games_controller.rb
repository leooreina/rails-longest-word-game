require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now
    session[:letters] = @letters
    session[:start_time] = @start_time
  end

  def score
    @word = params[:word]
    in_grid = letter_in_grid
    overused = check_overuse_letter
    if in_grid & !overused
      if word_exists?
        @result = "<strong>Congratulations!</strong> #{@word.upcase!} is a valid English word!".html_safe
        @score = set_score(Time.now - Time.parse(session[:start_time]))
      else
        @result = "Sorry but <strong>#{@word.upcase!}</strong> does not seem to be a valid English word...".html_safe
        @score = 0
      end
    else
      @result = "Sorry but <strong>#{@word.upcase!}</strong> can't be built out of #{session[:letters].split(' ').join(', ')}".html_safe
      @score = 0
    end
  end

  def generate_grid(grid_size)
    grid_counter = 0
    random_letters = []
    while grid_counter != grid_size
      random_letters.push(('A'..'Z').to_a.sample)
      grid_counter += 1
    end
    random_letters
  end

  def word_exists? 
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    data_serialized = URI.open(url).read
    data = JSON.parse(data_serialized)
    data["found"]
  end

  def letter_in_grid
    word_array = @word.chars
    letter_count = word_array.map { |letter| session[:letters].count(letter.upcase) }
    letter_count.count(0).zero?
  end

  def check_overuse_letter
    word_array = @word.chars
    overused_array = word_array.map { |letter| word_array.count(letter) <= session[:letters].count(letter.upcase) }
    overused_array.count(false) != 0
  end

  def set_score(time)
    if time > 10
      score = time * 10
    elsif time < 10
      score = time * 1000
    end
    score * @word.length
  end
end
