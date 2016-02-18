class Dictionary
	def initialize
		@random_dic = $CURRENT_DIR + '/dics/random.txt'
		@pattern_dic = $CURRENT_DIR + '/dics/pattern.txt'

		@random = []					# ランダム辞書読み込み
		open(@random_dic) do |f|
			f.each do |line|
				line.force_encoding("utf-8").chomp!
				next if line.empty?
				@random.push(line)
			end
		end

		@pattern = []					# パターン辞書読み込み
		open(@pattern_dic) do |f|
			f.each do |line|
				pattern, phrases = line.force_encoding("utf-8").chomp!.split("\t")
				next if pattern.nil? or phrases.nil?
				@pattern.push(PatternItem.new(pattern, phrases))
			end
		end
	end

	def study(input)
		return if @random.include?(input)
		@random.push(input)
	end

	def save
		open(@random_dic, 'w') do |f|
			f.puts(@random)
		end
	end


	attr_reader :random, :pattern
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

	attr_reader :modify, :pattern, :phrases
end
