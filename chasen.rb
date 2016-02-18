#! ruby -Ku

$CURRENT_DIR = Dir::pwd + '/../kana-morph2'
#$CURRENT_DIR = '/home/se-ichi/public_html/kana'
# puts $CURRENT_DIR  # デバッグ用
$LOAD_PATH.push($CURRENT_DIR)

require 'chasen.so'
require 'nkf'

module Chasen
	# option = "-F%m %P-\t"
	def setarg(option)
		Chasen.getopt(option, "-i", "w")
		# -i w : 文字コードUTF-8
	end

	def analyze(text)
		# -X:半角を全角に W:出力UTF-8 w:入力UTF-8
		text = NKF::nkf('-XWw', text)
		return Chasen.sparse(text)
	end
	module_function :setarg, :analyze
end

if $0 == __FILE__		# chasen.rbが直接実行されたたとき
						# $0 ・・・ 実行しているスクリプトファイル
						# 現在のファイル(chasen.rb)
	Chasen.getopt("-F%m %P-\n","-i", "w")

	puts '文字を入力してください'
	while line = gets() do 
		line.chomp!
		break if line.empty?
		line = NKF::nkf('-XWw', line)
		puts Chasen::analyze(line)
	end
end
