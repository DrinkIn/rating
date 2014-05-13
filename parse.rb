#!/usr/bin/env ruby
require 'multi_xml'
require 'csv'

class String
  def first_word
    self.split[0]
  end
  def first_word_upcase?
    fw = self.first_word
    fw === fw.upcase and fw.alpha?
  end

  def alpha?
    !!match(/^[[:alpha:]]+$/)
  end
end
AWARD_FW = %w(DOUBLE BEST GOLD BRONZE SILVER)
class Product
  attr_accessor :text, :top, :category, :diff, :awards, :name, :abv, :region, :price

  def awards
    @awards.join '|'
  end

  def to_s
    self.inspect
  end
end

accum = []
category = nil
ARGF.each do |line|
  data = MultiXml.parse(line)['text']
  font = data['font'].to_i
  text = data['__content__'] || data['b']
  if font == 2
    product = Product.new
    product.top = data['top'].to_i
    product.category = category
    product.text = text
    accum << product
  elsif font == 1
    category = text.strip
  end
end

lines = []
accum.each_with_index do |l, i|
  prev_line = accum[i - 1] if i > 0
  if prev_line
    diff = l.top - prev_line.top
    l.diff = diff
    if (diff >= 0 && diff < 16) || l.text[0] == ','
      lines[-1].text += " " + l.text
    else
      lines << l
    end
  else
    lines << l
  end
end


products = lines.map do |l|
  parts = l.text.split(',')
  l.awards = []
  rest = []

  # Parse awards
  parts.each do |p|
    if AWARD_FW.include? p.first_word
      l.awards << p.strip
    else
      rest << p
    end
  end

  # Parse title
  l.name = rest.shift.strip
  leftover = rest.join(',')

  abv_match = /\[(.*?)\]/.match(leftover)
  price_match = /\$(.*?)\./.match(leftover)

  if abv_match and price_match
    l.abv = abv_match[1]
    l.region = abv_match.pre_match.strip
    l.price = price_match[1]
    l.text = price_match.post_match.strip
  elsif abv_match and !price_match
    l.abv = abv_match[1]
    l.region = abv_match.pre_match.strip
    l.text = abv_match.post_match.split('Need Price,').first.strip
  elsif !abv_match and price_match
    l.region = price_match.pre_match.strip
    l.price = price_match[1]
    l.text = price_match.post_match.strip
  else
    leftover_parts = leftover.split('Need Price,')
    l.region = leftover_parts[0].strip
    l.text = leftover_parts[1].strip
  end

  l
end
CSV.open('csv/2014.csv', 'w') do |csv|
  headers = ['name', 'awards', 'region', 'price', 'category', 'text']
  csv << headers
  products.each do |p|
    row = headers.map do |field|
      p.send(field.to_sym)
    end

    csv.puts row
  end
end
