class LongestWordController < ApplicationController


  URL = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=78b21c04-6593-4f5b-a78d-a4198daa8da0&input="

  def game
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    @attempt = params[:attempt]
    grid = get_grid_from_string(params[:grid])
    start_time = Time.parse(params[:start_time])

    @results = run_game(@attempt, grid, start_time, end_time)
  end

  private

  def get_grid_from_string(grid_string)
    return grid_string.gsub!(/\W+/, '').chars
  end

  def message_to_return(attempt, translation, verif)
    if translation != attempt && verif
      return "well done"
    elsif !verif
      return "not in the grid"
    else
      return "not an english word"
    end
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    (1..grid_size).each { grid << [*('A'..'Z')].sample }
    return grid
  end

  def run_game(attempt, grid, start_time, end_time)
    translation = JSON.parse(open(URL + attempt).read)["outputs"][0]["output"]

    score = 0
    verif = true
    attempt.upcase.chars.each do |letter|
      grid.find_index(letter).nil? ? verif = false : grid.delete_at(grid.find_index(letter))
    end

    score = (attempt.size.to_f / grid.size / (end_time - start_time)) * 10 if translation != attempt && verif

    message = message_to_return(attempt, translation, verif)
    translation = nil unless message == "well done"

    return { time: end_time - start_time, translation: translation, score: score, message: message }
  end
end

# require 'open-uri'
# require 'json'

