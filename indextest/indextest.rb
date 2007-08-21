## indextest.rb
## TODO: Write get term vector hash
## 


require 'rubygems'
require 'ferret'
include Ferret


#Ferret extension

class Index::Index 
  def tf(term,docId)
    #te = index.reader.terms(:text)
    #tv = index.reader.term_vector(docId,:text)
    #tv.terms.each {|t| puts "term #{t.text}  with  #{t.positions.size}" }
  end
end



class VSM
end
  

  
class MiguelBiAnalyzer <  Ferret::Analysis::Analyzer
  include Ferret::Analysis

  def initialize(stop_words = Analysis::FULL_SPANISH_STOP_WORDS, lower = true)
    @lower = lower
    @stop_words = stop_words
    puts "Hello world"
    
  end
  
  def token_stream(field, str)
    ts = StandardTokenizer.new(str)
    ts = LowerCaseFilter.new(ts) if @lower
    ts = StopFilter.new(ts, @stop_words)
    ts = StopFilter.new(ts, Analysis::FULL_ENGLISH_STOP_WORDS)
    ts = HyphenFilter.new(ts)
    ts = StemFilter.new(ts,"spanish")
    #ts = StemFilter.new(ts,"english")
    
  end
end



index = Index::Index.new(:analyzer =>  MiguelBiAnalyzer.new)

data_directory = "data"

Dir.entries(data_directory).each do |entry|
  if (entry == "." or entry == "..") 
  else
    index << {:filename => 'entry',:text => IO.readlines(data_directory+"/"+entry)}
  end
  
# index.search_each('text:"miguel"') do |id, score|
#     puts "Document #{id} found with a score of #{score}"
#   end
 
end

te = index.reader.terms(:text)
tv = index.reader.term_vector(14,:text)
  
#tv.terms.each {|t| puts "term #{t.text}  with  #{t.positions.size}" }
#puts Analysis::FULL_SPANISH_STOP_WORDS
#x = MiguelBiAnalyzer.new


te.each {|term, doc_freq| puts "#{term} occured #{doc_freq} times" }

