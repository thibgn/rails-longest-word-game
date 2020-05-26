require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    session[:score] = 0 if session[:score].nil?
    session[:played] = 0 if session[:played].nil?

    alpha = ('A'..'Z').to_a
    @letters = []
    9.times do
      @letters << alpha.sample(1).join
    end
    @start_time = Time.now
  end

  def score
    @result = {}

    @word = params[:word]
    @grid = params[:grid]
    @start = params[:start].to_i
    @end = Time.now

    @result[:time] = @end - @start
    @result[:time] < 2 ? time = 10 : time = 1
    @result[:score] = @word.size * time

    url = "https://wagon-dictionary.herokuapp.com/"
    word_check = JSON.parse(open(url + @word).read)
    rgx = Regexp.new "[" + @grid + "]"

    def any_doubles?(attempt, grid)
      check_attempt = {}
      check_grid = {}
      attempt.upcase.split('').each { |l| check_attempt.key?(l) ? check_attempt[l] += 1 : check_attempt[l] = 1 }
      grid.split('').each { |l| check_grid.key?(l) ? check_grid[l] += 1 : check_grid[l] = 1 }
      check = check_grid.map { |k, v| v - check_attempt[k].to_i }
      return check.any?(&:negative?)
    end

    if word_check['found'] == false
      @result[:message] = "This is not an english word"
      @result[:score] = 0
    elsif (@word.upcase.scan(rgx).size == @word.size) && any_doubles?(@word, @grid) == false && @word.length > 0
      @result[:message] = "You score, well done"
    elsif @word.length == 0
      @result[:message] = "You must type a word bro"
    else
      @result[:message] = "Your letters are not in the grid ;)"
      @result[:score] = 0
    end
    session[:played] += 1
    session[:score] += @result[:score]
  end
end
