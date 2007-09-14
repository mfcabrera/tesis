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
        |t| puts "index::tf:  #{t.text}  with  #{t.positions.size}" 
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
      
end


#personalized classes... I should extend Ferret
#but well... some day I'll do it properly
class TermInfo
    attr_accessor :idf
    attr_accessor :word_freq
    attr_accessor :tf
    
    def initialize(termstr)
         @term = termstr
    end       
end

class DocumentInfo
    attr_accessor :words,:id,:total_words
    def initialize(id,words,ireader)
        self.id = id
        self.words = words
        self.total_words = 0
        
        ireader.term_vector(id,:text).terms.each do |t| 
                self.words[t.text].word_freq = t.positions.size
                self.total_words = self.total_words + self.words[t.text].word_freq
                puts "#{t.text} - #{t.positions.size}" 
        end
       
        calculate_tf_df
               
    end 
    
    def calculate_tf
             
        self.words.each  { |k,v| 
            v.tf = v.word_freq/(self.total_words.to_f)    
            puts "#{k} - #{v.tf}"
        }
                    
    end    
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

#write into IndexReader
all_words = Hash.new
te.each {|term,doc_freq|
        #Here we should create all VECTOR META-HASH so we can save Database information about it.. it will a big big hash
        all_words[term] = TermInfo.new(term)
        all_words[term].idf = Math::log(index.reader.num_docs.to_f/doc_freq.to_f)
        all_words[term].word_freq = 0.0
              
        #|term, doc_freq| 
		puts "#{term} idf-> #{all_words[term].idf}" 
		#sum_nk =  sum_nk + doc_freq
}

#now for aeach document we find the words hash but sorted

#doc = DocumentInfo.new(1,all_words.clone,index.reader)

#make it an inter function





