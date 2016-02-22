require 'yahoo'

module Morph
	def analyze(text)
		# Yahooから配列で解析結果を受け取る
		texts = Yahoo::analyze(text)
#		print "(morph) => "
#		puts texts
		return texts
#		return texts.chomp.split(/\t/).map do |part|
#			part.split(/ /)
#		end
	end

	def keyword?(part)
		return /名詞/ =~ part
	end

	module_function :analyze, :keyword?
end
