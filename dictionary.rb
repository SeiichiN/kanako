require 'morph'
require 'markov'
require 'utils'

class Dictionary
	def initialize
		@random_dic = $CURRENT_DIR + '/dics/random.txt'
		@pattern_dic = $CURRENT_DIR + '/dics/pattern.txt'
		@template_dic = $CURRENT_DIR + '/dics/template.txt'
		@markov_dic = $CURRENT_DIR + '/dics/markov.dat'

		load_random
		load_pattern
		load_template
		load_markov
	end

	def load_random
		@random = []
		begin					# ランダム辞書読み込み
			open(@random_dic) do |f|
				f.each do |line|
					line.force_encoding("utf-8").chomp!
					next if line.empty?
					@random.push(line)
				end
			end
		rescue => e
			puts(e.message)
			@random.push('こんにちは')
		end
	end

	def load_pattern
		@pattern = []
		begin					# パターン辞書読み込み
			open(@pattern_dic) do |f|
				f.each do |line|
					pattern, phrases = line.force_encoding("utf-8").chomp!.split("\t")
					next if pattern.nil? or phrases.nil?
					@pattern.push(PatternItem.new(pattern, phrases))
				end
			end
		rescue => e
			puts(e.message)
		end
	end

	def load_template
		@template = []
		begin
			open(@template_dic) do |f|
				f.each do |line|
					count, template = line.force_encoding("utf-8").chomp.split(/\t/)
					next if count.nil? or pattern.nil?
					count = count.to_i
					@template[count] = [] unless @template[count]
					@template[count].push(template)
				end
			end
		rescue => e
			puts(e.message)
		end
	end

	def load_markov
		@markov = Markov.new
		begin
			open(@markov_dic, 'rb') do |f|
				@markov.load(f)
			end
		rescue => e
			puts(e.message)
		end
	end

	def study(input, parts)
		study_random(input)
		study_pattern(input, parts)
		study_template(parts)
		study_markov(parts)
	end

	def study_random(input)
		return if @random.include?(input)
		@random.push(input)
	end

	def study_pattern(input, parts)
		parts.each do |word, part|

		# force_encodingはYahooAPIでは必要ないみたい・・・
#			word = word.force_encoding("utf-8")
#			part = part.force_encoding("utf-8")

			# print "(dictionary)word => #{word} "		# デバッグ用 word=ことば
			# print "(dictionary)part => #{part} "		# デバッグ用 part=品詞情報

			next unless Morph::keyword?(part)
			duped = @pattern.find{|ptn_item| ptn_item.pattern == word}
			if duped
				duped.add_phrase(input)		# ユーザーの言葉を登録
#				print "キーワード「#{word}」の応答に「#{input}」を登録したよ。<br>"
			else
				@pattern.push(PatternItem.new(word, input))		# 新しい組み合わせとして登録
#				print "新しくキーワード「#{word}」とその応答「#{input}」を登録したよ。<br>"
			end
		end
	end

	def study_template(parts)
		template = ''
		count = 0
		parts.each do |word, part|
			word.force_encoding("utf-8")
			part.force_encoding("utf-8")

			# print "word => #{word}<br>\n"		# for debugg
			# print "part => #{part}<br>\n"		# for debugg

			if Morph::keyword?(part)
				word = '%noun%'
				count += 1
			end
			template += word
		end
		return unless count > 0

		@template[count] = [] unless @template[count]
		unless @template[count].include?(template)
			@template[count].push(template)
#			print "#{count}のtemplateに#{template}を追加したよ。<br>\n"		# デバッグ用
		end
	end

	def study_markov(parts)
		@markov.add_sentence(parts)
	end

	def save
		open(@random_dic, 'w') do |f|
			f.puts(@random)
		end

		open(@pattern_dic, 'w') do |f|
			@pattern.each{|ptn_item| f.puts(ptn_item.make_line)}
		end

		open(@template_dic, 'w') do |f|
			@template.each_with_index do |templates, i|
				next if templates.nil?
				templates.each do |template|
					f.puts(i.to_s + "\t" + template)
				end
			end
		end

		open(@markov_dic, 'wb') do |f|
			@markov.save(f)
		end
	end

	attr_reader :random, :pattern, :template, :markov
end

class PatternItem
	SEPARATOR = /^((-?\d+)##)?(.*)$/		# (2)

	def initialize(pattern, phrases)			# (3)
		SEPARATOR =~ pattern
		@modify, @pattern = $2.to_i, $3		# (4)

		@phrases = []						# (5)
		phrases.split('|').each do |phrase|
			# パターン辞書の応答部分をphraseに入れて、正規表現とのマッチを調べる
			SEPARATOR =~ phrase
			# 先頭の数字をneedに入れて、応答言葉をphraseに入れる
			@phrases.push({'need' => $2.to_i, 'phrase' => $3})
			# デバッグ用
#			print "@phrases => #{@phrases}"
#			puts "<br>"
#			puts @phrases[0]['need']
#			puts @phrases[0]['phrase']
#			puts "<br>"
		end
	end

	def match(str)							# (6)
		return str.match(@pattern)
	end

	def choice(mood)						# (7)
		choices = []
		@phrases.each do |p|
			choices.push(p['phrase']) if suitable?(p['need'], mood)
		end
		return (choices.empty?)? nil : select_random(choices)
	end

	def suitable?(need, mood)				# (8)
		return true if need == 0
		if need > 0
			return mood > need
		else
			return mood < need
		end
	end

	def add_phrase(phrase)
		return if @phrases.find{|p| p['phrase'] == phrase}
		@phrases.push({'need' => 0, 'phrase' => phrase})
	end

	def make_line
		pattern = @modify.to_s + "##" + @pattern
		phrases = @phrases.map{|p| p['need'].to_s + "##" + p['phrase']}
		return pattern + "\t" + phrases.join('|')
	end

	attr_reader :modify, :pattern, :phrases
end
