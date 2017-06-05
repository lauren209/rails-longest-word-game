class WordgameController < ApplicationController


  # require 'open-uri'
  # require 'json'
  # require "time"


  def game
    @grid = generate_grid
    @start_time = Time.now
  end

  def score

    @start_time = params[:time].to_datetime
    @end_time = Time.now
    @grid = params[:grid].split(" ")
    @my_guess = params[:response]
    @score = run_game(@my_guess, @grid, @start_time, @end_time)

  end



  private

  def generate_grid
  # TODO: generate random grid of letters
    grid_size = 9
    letters = ("a".."z").to_a
    @grid_letters = []
    i = 0
    while i < grid_size
      @grid_letters << letters.sample
      i += 1
    end
    @grid_letters
  end




  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "9492d106-1f8d-432d-90da-7ec89f75552a"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        @transed = word
      else
        return nil
      end
    end
  end

end
