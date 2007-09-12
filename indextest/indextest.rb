## indextest.rb
## TODO: Write get term vector hash
## 


require 'rubygems'
require 'ferret'
include Ferret


#Ferret extension

class Index::IndexReader 
  def tf(docId)
    #te = index.reader.terms(:text)
    tv = self.term_vector(docId,:text)
    vect = Hash.new
    tv.terms.each {
        |t| puts "term #{t.text}  with  #{t.positions.size}" 
        vect[t.text] = t.positions.size
    }
    vect
  end
  
  def sum_nk      
  te = self.terms(:text)
  sum_nk = 0
    te.each {|term, doc_freq| 
		puts "#{term} occured #{doc_freq} times" 
		sum_nk =  sum_nk + doc_freq

    }   
  end 
  
  def cololo 
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
#tv = index.reader.term_vector(14,:text)
  
#tv.terms.each {|t| puts "term #{t.text}  with  #{t.positions.size}" }
#puts Analysis::FULL_SPANISH_STOP_WORDS
#x = MiguelBiAnalyzer.new
sum_nk = 0
te.each {
        #Here we should create all VECTOR META-HASH so we can save Database information about it.. it will a big big hash

        |term, doc_freq| 
		puts "#{term} occured #{doc_freq} times" 
		sum_nk =  sum_nk + doc_freq

}



puts "Sum Nk = #{sum_nk}"
index.reader.tf(1).each_pair {|k,v| puts "#{k}:\t#{v}" }




