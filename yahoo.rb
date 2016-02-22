#!/usr/local/bin/ruby -Ku

require 'open-uri'
require 'rexml/document'
require 'nkf'

module Yahoo
	def analyze(text)
		# アプリケーションIDのセット
		id = "dj0zaiZpPVlvYW42alJDZTdJcyZzPWNvbnN1bWVyc2VjcmV0Jng9YzI-"
		# 形態素解析したい文章
		# -X:半角を全角に W:出力UTF-8 w:入力UTF-8
		text = NKF::nkf('-XWw', text)
		# URLの組み立て
		url = "http://jlp.yahooapis.jp/MAService/V1/parse?appid=" + 
			"#{id}" + "&results=ma&sentence=" + URI.encode(text)
		response = open(url)
		# 戻り値をパースする
		parse = REXML::Document.new(response).elements[
			'ResultSet/ma_result/word_list/']
		# 戻り値（オブジェクト）からループでデータを取得する
		kekka = []
		parse.elements.each('word') do |ele|
			words = ele.elements["surface"][0].to_s
			parts = ele.elements["pos"][0].to_s
			ary = [words, parts]
			kekka.push( ary )
		end
		return kekka
	end

	module_function :analyze
end

if $0 == __FILE__		# chasen.rbが直接実行されたたとき
						# $0 ・・・ 実行しているスクリプトファイル
						# 現在のファイル(chasen.rb)

	puts '文字を入力してください'
	while line = gets() do 
		line.chomp!
		break if line.empty?
		puts Yahoo::analyze(line)
	end
end
