require 'utils'

class Responder
	def initialize(name, dictionary)
		@name = name
    @dictionary = dictionary
	end
	
	def response(input, parts, mood)
		return ''
	end
	
	attr_reader :name
end

class WhatResponder < Responder
	def response(input, parts, mood)
		return "#{input}ってなに？"
	end
end

class RandomResponder < Responder
  def response(input, parts, mood)
    return select_random(@dictionary.random)
  end
end

class PatternResponder < Responder
  def response(input, parts, mood)
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

class TemplateResponder < Responder
  def response(input, parts, mood)
    keywords = []
    parts.each do |word, part|
#      word.force_encoding("utf-8")        # added by SeiichiN
#      part.force_encoding("utf-8")        # added by SeiichiN
      if Morph::keyword?(part)
        keywords.push(word)
        # print "配列keywordsに「#{word}」を入れたよ<br>\n"  # デバッグ用
      end
    end
    count = keywords.size
    if count > 0 and templates = @dictionary.template[count]
      template = select_random(templates)
      # print "選択したtemplateは => #{template}だよ。<br>\n"   # for debugg
        # %noun%をkeywordsに入っている名詞でおきかえる shiftは配列の先頭要素を取り出す
      return template.gsub(/%noun%/){keywords.shift}
    end

    return select_random(@dictionary.random)
  end
end

class MarkovResponder < Responder
  def response(input, parts, mood)
#    keyword, p = parts.find{|w, part| Morph::keyword?(part.force_encoding("utf-8"))}
    keyword, p = parts.find{|w, part| Morph::keyword?(part)}
    resp = @dictionary.markov.generate(keyword)
    return resp unless resp.nil?

    return select_random(@dictionary.random)      
  end
end
