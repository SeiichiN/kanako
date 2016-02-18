#!/usr/local/bin/ruby -Ku

require 'open-uri'
require 'rexml/document'

# アプリケーションIDのセット
id = "dj0zaiZpPVlvYW42alJDZTdJcyZzPWNvbnN1bWVyc2VjcmV0Jng9YzI-";
# 形態素解析したい文章
word = "わたしは恋するプログラムの女の子です。";
# URLの組み立て
url = "http://jlp.yahooapis.jp/MAService/V1/parse?appid=" + 
	"#{id}" + "&results=ma&sentence=" + URI.encode(word);
response = open(url)
# 戻り値をパースする
parse = REXML::Document.new(response).elements[
	'ResultSet/ma_result/word_list/'];
# 戻り値（オブジェクト）からループでデータを取得する
parse.elements.each('word') do |ele|
	print ele.elements["surface"][0]
	print "\t"
	print ele.elements["pos"][0]
	print "｜"
end

puts "終了"
