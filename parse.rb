#!/usr/bin/env ruby
require 'multi_xml'
class String
  def first_word
    self.split[0]
  end
  def first_word_upcase?
    fw = self.first_word
    fw === fw.upcase && fw.length >= 4
  end
end

accum = []
category = nil
ARGF.each do |line|
  data = MultiXml.parse(line)['text']
  font = data['font'].to_i
  text = data['__content__'] || data['b']
  # if font == 1
  #   category = text
  # elsif font == 2
  #   if text.first_word_upcase?
  #     accum << text
  #   else
  #     accum[-1] += text
  #   end
  # end
  accum << text
end

puts accum.map { |a| a.first_word }.select { |a| a.upcase === a }
# accum.each do |l|
#   pos = l.rindex 'Medal'
#   if pos
#     # puts l[0,pos]
#   else
#     puts l
#   end
# end
