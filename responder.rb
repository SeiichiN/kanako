class Responder
	def initialize(name, dictionary)
		@name = name
    @dictionary = dictionary
	end
	
	def response(input, mood)
		return ''
	end
	
	attr_reader :name
end

class WhatResponder < Responder
	def response(input, mood)
		return "#{input}ってなに？"
	end
end

class RandomResponder < Responder
  def response(input, mood)
    return select_random(@dictionary.random)
  end
end

class PatternResponder < Responder
  def response(input, mood)
    @dictionary.pattern.each do |ptn_item|
      # 辞書の言葉と入力された文字が一致すれば、その文字をmに入れる
      if m = ptn_item.match(input)
        resp = ptn_item.choice(mood)
        # print "resp => #{resp}<br>"  # デバッグ用
        next if  resp.nil?
        return resp.gsub(/%match%/, m.to_s)
          # gsub 第1引数に指定した正規表現にマッチしたすべての文字列を第2引数の文字列で置き換え、
              # 置き換えた結果の文字列を返す
      end
    end

    # 辞書の言葉とマッチするものがなければ、ランダムに返答
    return select_random(@dictionary.random)
  end
end
