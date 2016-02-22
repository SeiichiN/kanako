#! ruby -Ku
$CURRENT_DIR = Dir::pwd + '/../kanako'
$LOAD_PATH.push($CURRENT_DIR)

require 'morph'
require 'utils'

class Markov
	ENDMARK = '%END%'
	CHAIN_MAX = 30

	def initialize
		@dic = {}				# マルコフ辞書
		@starts = {}		# 文章が始まる単語
	end

	def add_sentence(parts)				# 文章の学習 partsは形態素解析結果
		return if parts.size < 3		# 学習する文章は３単語以上とする

		parts = parts.dup          # 解析結果のコピー
		# 解析結果の先頭２単語をprefix1、prefix2に入れる
		prefix1, prefix2 = parts.shift[0], parts.shift[0]
		add_start(prefix1)

		parts.each do |suffix, part|
			add_suffix(prefix1, prefix2, suffix)
			prefix1, prefix2 = prefix2, suffix
		end
		add_suffix(prefix1, prefix2, ENDMARK)
	end

	def generate(keyword)
		return nil if @dic.empty?				# 辞書が空っぽの時

		words = []
			## 辞書@dicにkeywordがあればkeywordを代入する。なければselect_startメソッドを呼び出す
		prefix1 = (@dic[keyword])? keyword : select_start
			# prefix1をキーとする単語をprefix2に代入してるのかな？
		prefix2 = select_random(@dic[prefix1].keys)
		words.push(prefix1, prefix2)
		CHAIN_MAX.times do
				# prefix1、prefix2をキーとする単語をsuffixに代入してるのかな？
			suffix = select_random(@dic[prefix1][prefix2])
			break if suffix == ENDMARK
			words.push(suffix)
				# prefix2をprefix1とする。suffixをprefix2とする。
			prefix1, prefix2 = prefix2, suffix
		end
		return words.join			# 配列の各要素を結合して文章とする。
	end

	def load(f)
		@dic = Marshal::load(f)
		@starts = Marshal::load(f)
	end

	def save(f)
		Marshal::dump(@dic, f)
		Marshal::dump(@starts, f)
	end

	private
	def add_suffix(prefix1, prefix2, suffix)
		@dic[prefix1] = {} unless @dic[prefix1]
		@dic[prefix1][prefix2] = [] unless @dic[prefix1][prefix2]
		@dic[prefix1][prefix2].push(suffix)
	end

	def add_start(prefix1)
			# @startの配列は、prefix1をハッシュキーとしている。値は数字（登録した回数）
		@starts[prefix1] = 0 unless @starts[prefix1]
		@starts[prefix1] += 1
	end

	def select_start
			# keys・・・ハッシュである@startのキーを取り出して配列としている。
		return select_random(@starts.keys)
	end
end

if $0 == __FILE__
#	Morph::init_analyzer

	markov = Markov.new
	while line = gets do
#		texts = line.force_encoding("utf-8")
		texts = line.chomp.split(/[。?？!！ 　]+/)
		texts.each do |text|
			next if text.empty?
			markov.add_sentence(Morph::analyze(text))
			print '.'
		end
	end
	puts

	loop do
		print '> '
			# キーボードからの入力を強制的に受け取らせる(getsでキーボードからの入力待ちにならない「My開発メモ」)
		line = STDIN.gets.chomp
		break if line.empty?
			# 標準入力を念のためutf-8にしておく。
		line.force_encoding("utf-8")
			# キーボードからの入力を品詞分解してハッッシュにする。parts{'word' => 'part', 'word' => 'part',・・・}
		parts = Morph::analyze(line)
			# part部分の名詞を探し出して、keywordに入れる。
		keyword, p = parts.find{|w, part| Morph::keyword?(part.force_encoding("utf-8"))}
			# keywordをもとにして、マルコフ文章を生成する。
		puts(markov.generate(keyword))
	end
end

