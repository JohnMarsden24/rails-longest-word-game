require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(9) { ('A'..'Z').to_a.sample }
  end

  def score
    @guess = params[:guess]
    @letters = params[:letters].split
    @result = check_word(@guess, @letters)
  end

  def check_word(guess, letters)
    result = {}
    if in_grid?(guess, letters) && valid_guess?(guess)
      result[:message] = "Congratulations! #{guess.upcase} is a valid English word!"
      result[:score] = session_score(@guess.length)
    elsif valid_guess?(guess)
      result[:message] =  "Sorry but #{guess.upcase} can't be built out of #{letters}"
    else
      result[:message] =  "Sorry but #{guess.upcase} does not seem to be a valid English word"
    end
    return result
  end

  def session_score(guess)
    session[:score].nil? ? session[:score] = guess : session[:score] += guess
  end

  def valid_guess?(guess)
    response = open("https://wagon-dictionary.herokuapp.com/#{guess}")
    json = JSON.parse(response.read)
    return json["found"]
  end

  def in_grid?(guess, letters)
    guess.upcase!
    guess.chars.all? { |letter| guess.count(letter) <= letters.count(letter) }
  end
end
