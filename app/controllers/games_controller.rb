require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    @start_time = Time.now
    10.times do |i|
      i = ('A'..'Z').to_a.sample
      @letters << i
    end
    @letters
  end

  def parse(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    attempt_serialized = open(url).read
    JSON.parse(attempt_serialized)
  end

  def word_in_the_grid?(word, letters)
    grid_letters = Hash.new(0)
    letters.map(&:downcase).each { |letter| grid_letters[letter] += 1 }
    word.downcase.split('').each { |letter| grid_letters[letter] -= 1 }
    grid_letters.values.min >= 0
  end

  def result(in_the_grid, is_english, word, letters)
    case [is_english, in_the_grid]
    when [true, true]
      "Congratulation! #{word.upcase} is a valid English word!"
    when [true, false]
      "sorry but #{word.upcase} can't be build out of #{letters.join(',')}"
    else
      "Sorry but #{word.upcase} does not seem to be a valid English word.."
    end
  end

  def scoring(input, in_the_grid, is_english, total_time)
    in_the_grid && is_english ? input.length * (1 / total_time) + 1 : 0
  end

  def score
    @result = {}
    @input = params[:word]
    @letters = params[:grid].split(' ')
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @total_time = @end_time - @start_time

    answer = parse(@input)
    in_the_grid = word_in_the_grid?(@input, @letters)
    is_english = answer['found']
    @result[:time] = @total_time
    @result[:score] = scoring(@input, in_the_grid, is_english, @total_time)
    @result[:message] = result(in_the_grid, is_english, @input, @letters)
  end
end
