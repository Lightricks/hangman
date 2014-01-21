require 'sinatra'
require 'base64'
require 'json'
require './lib/hangman'

class HangmanApp < Sinatra::Base

  before do
    headers['Access-Control-Allow-Origin'] = '*'
  end

  post '/hangman' do
    hangman = Hangman.new(Dictionary.random_word)

    return_json({ hangman: hangman.to_s, token: token(hangman) })
  end

  put '/hangman' do
    letter = params["letter"]
    word, correct_guesses, wrong_guesses = params_from_token(params["token"])
    hangman = Hangman.new(word, correct_guesses, wrong_guesses)
    guess = hangman.guess(letter)
    hangman_string = hangman.to_s

    return_json({ hangman: hangman_string, correct: guess, token: token(hangman) })
  end

  def token(hangman)
    Base64.urlsafe_encode64({solution: hangman.solution,
                             correct_guesses: hangman.correct_guesses,
                             wrong_guesses: hangman.wrong_guesses}.to_s)
  end

  def params_from_token(token)
    properties = eval(Base64.urlsafe_decode64(token))

    [ properties[:solution], properties[:correct_guesses], properties[:wrong_gueses]  ]
  end

  def return_json(data)
    content_type 'application/json'
    data.to_json
  end

  class Dictionary
    def self.random_word word=nil
      loop do
        word = File.read("words").split("\n").sample
        return word if word.length > 3
      end
      word
    end
  end
end