pdftohtml -xml -stdout -i raw/2014_ResultsByClass.pdf \
  | grep text \
  | ./parse.rb
