require 'responder'
require 'dictionary'
require 'morph'

class Unmo
  def initialize(name, mood)
    @name = name

    @dictionary = Dictionary.new
    @emotion = Emotion.new(@dictionary, mood)

    @resp_what = WhatResponder.new('What', @dictionary)      # (1)
    @resp_random = RandomResponder.new('Random', @dictionary)
    @resp_pattern = PatternResponder.new('Pattern', @dictionary)
    @resp_template = TemplateResponder.new('Template', @dictionary)
    @resp_markov = MarkovResponder.new('Markov', @dictionary)
    @responder = @resp_pattern
  end

  def dialogue(input)
    @emotion.update(input)

#    print "_unmo_ @emotion.mood => #{@emotion.mood}<br>" # for debugg
    input = 'わたしはプログラムの女の子です。' if input == ""  # for debugg

    parts = Morph::analyze(input)

    case rand(100)
    when 0..29
      @responder = @resp_pattern
    when 30..49
      @responder = @resp_template
    when 50..69
      @responder = @resp_random
    when 70..89
      @responder = @resp_markov
    else
      @responder = @resp_what
    end

    # デバッグ用
    # print "input => #{input}<br>"
    # print "@emotion.mood => #{@emotion.mood}<br>"
    # ここまで

    resp = @responder.response(input, parts, @emotion.mood)

    # for debug
    #print "(unmo)resp => "
    #puts resp
    # ここまで

    @dictionary.study(input, parts)
    @dictionary.save
    
    return resp
  end

  def save
    @dictionary.save
  end

  def responder_name
    return @responder.name
  end

  def mood
    return @emotion.mood
  end

  attr_reader :name
end

class Emotion
  MOOD_MIN = -15
  MOOD_MAX = 15
  MOOD_RECOVERY = 0.5

  def initialize(dictionary, mood)
    @dictionary = dictionary
    @mood = mood
  end

  def update(input)
    @dictionary.pattern.each do |ptn_item|
      if ptn_item.match(input)
#        print "_unmo.rb_ ptn_item.modify => #{ptn_item.modify}<br>" # デバッグ用
        adjust_mood(ptn_item.modify)
        break
      end
    end

    if @mood < 0
      @mood += MOOD_RECOVERY
    elsif @mood > 0
      @mood -= MOOD_RECOVERY
    end
  end

  def adjust_mood(val)
#    print "_unmo.rb_ val => #{val}<br>" # for debbug
    @mood += val
#    print "_unmo.rb_ @mood => #{@mood}<br>"  #for debbug
    if @mood > MOOD_MAX
      @mood = MOOD_MAX
    elsif @mood < MOOD_MIN
      @mood = MOOD_MIN
    end
  end

  attr_reader :mood
end
