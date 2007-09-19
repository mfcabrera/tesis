## indextest.rb
## TODO: Write get term vector hash
## 


require 'rubygems'
require 'ferret'
include Ferret

  
class MiguelBiAnalyzer <  Ferret::Analysis::Analyzer
  include Ferret::Analysis

  def initialize(stop_words = Analysis::FULL_SPANISH_STOP_WORDS, lower = true)
    @lower = lower
    @stop_words = stop_words
    #puts "Hello world"
    
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


#Ferret extension

class Index::IndexReader 
    @changed = true

         
   def all_terms
           all_words = Hash.new
           ndocs = num_docs.to_f
           terms(:text).each do |term,doc_freq|
           #Here we should create all VECTOR META-HASH so we can save Database information about it.. it will a big big hash
           all_words[term] = TermInfo.new(term)
           all_words[term].idf = Math::log(ndocs/doc_freq.to_f)
           all_words[term].word_freq = 0.0
           all_words[term].tf_idf = 0.0                              
      	   #puts "#{term} idf-> #{all_words[term].idf}"   
	       end
       
        all_words
   end 
             
end


#personalized classes... I should extend Ferret
#but well... someday I'll do it properly
class TermInfo
    attr_accessor :idf
    attr_accessor :word_freq
    attr_accessor :tf
    attr_accessor :tf_idf
    
    def initialize(termstr)
         @term = termstr
    end       
end

class DocumentInfo
    #label = 1 -1 or 0 (for no Label, for transductive set)
    attr_accessor :terms,:id,:total_words,:label
    
    def initialize(id,ireader,label=0)
        
        @id = id
        @terms = ireader.all_terms
        @total_words = 0
        @label = label
        
        ireader.term_vector(id,:text).terms.each do |t| 
                @terms[t.text].word_freq = t.positions.size
                @total_words = @total_words + @terms[t.text].word_freq
#                puts "#{t.text} - #{t.positions.size}" 
        end
       
        calculate_tf_df
               
    end 
    
    def calculate_tf_df
        @terms.each  { |k,v| 
            v.tf = v.word_freq/(@total_words.to_f)
            v.tf_idf = v.idf*v.tf
        #    puts "#{k} - #{v.tf_idf}"
       }
                    
    end    
    
    def to_s
        s = "#{@label} "
        i = 1;
        @terms.each do |k,v| 
            if(v.tf_idf > 0.0) then
                s = s + "#{i}:#{v.tf_idf} "
            end
            i = i + 1    
        end
        s = s + "# #{@id}"
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




#now for aeach document we find the words hash but sorted

doc = DocumentInfo.new(1,index.reader)

puts doc
#make it an inter function





