require 'rubygems'
require 'ferret'
include Ferret


 
class MiguelBiAnalyzer <  Ferret::Analysis::Analyzer
  include Ferret::Analysis

  def initialize(stop_words = Analysis::FULL_ENGLISH_STOP_WORDS, lower = true)
    @lower = lower
    @stop_words = stop_words
    #puts "Hello world"
    
  end
  
  def token_stream(field, str)
    ts = StandardTokenizer.new(str)
    ts = LowerCaseFilter.new(ts) if @lower
    ts = StopFilter.new(ts, @stop_words)
    #ts = StopFilter.new(ts, Analysis::FULL_ENGLISH_STOP_WORDS)
    ts = HyphenFilter.new(ts)
    #ts = StemFilter.new(ts,"spanish")
    ts = StemFilter.new(ts,"english")
    
  end
end


#Ferret extension

class Index::IndexReader 
    @changed = true
   # @all_words = nil		
    
         
   def all_terms
	   
       	   @all_words = Hash.new
	   ndocs = num_docs.to_f
           terms(:text).each do |term,doc_freq|
	   #Here we should create all VECTOR META-HASH so we can save Database information about it.. it will a big big hash
           @all_words[term] = TermInfo.new(term)
	   @all_words[term].idf = Math::log(ndocs/doc_freq.to_f)
           @all_words[term].word_freq = 0.0
	   @all_words[term].tf_idf = 0.0                              
      		   #puts "#{term} idf-> #{all_words[term].idf}"   
	   end
        
        @all_words
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
    
    def full_s
        s = "#{@label} "
        i = 1;
        @terms.each do |k,v| 
           s = s + "#{v.tf_idf} "
           i = i + 1    
        end
        s
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
 

 #Create the idx for category 


 #idx_category(dir,cat,CATEGORY_STARTNUMBER[cat],50,index)
 


class DataSetIndexer 
	#TODO:
	#write_vect_category 

	#The text files should be in "./directory/category"
	#for being indexed properly
	attr_reader :index

	def initialize(directory,label = "1")
		@labels = Hash.new("-1")
		@categories = Array.new
		@dir = directory	
	end
	
	def create_index(index_name="dataset")
		
		@idx_name = index_name+".idx"
		
		@index = Index::Index.new(:key=>:id,:path=>@idx_name, :analyzer =>  MiguelBiAnalyzer.new,:create=>true)
	  
		@index.field_infos.add_field(:filename, :store => :yes,
                	                    :index => :no,
					    :term_vector => :no)
		@index.field_infos.add_field(:category, :store => :yes,
                	                    :index => :no,
					    :term_vector => :no)
		@index.field_infos.add_field(:text, :store => :yes,
                	                    :index => :yes,
                	                    :term_vector => :with_positions_offsets)
	
	end


	def index_category(category,start,n,label="1")
		
		@start = start
		@ndocs = n
		@categories << category
		
		start.upto(start + n-1)  do |i|
			#puts "indexing #{i}"
			@index << { :id=>i.to_s,:filename =>i.to_s, :category =>category, :text => IO.readlines(@dir+"/"+category+"/"+i.to_s) }	
			
		end

		outfile = File.open(@idx_name+".lab", File::WRONLY | File::APPEND | File::CREAT) 
		1.upto n do |i|
		 	outfile.write(label+"\n");	
		end
		outfile.close
		
		@indexed = true		
	end

	def index_category_no_label(category,start,n)
		@start = start
		@ndocs = n
		@categories << category
		
		start.upto(start + n-1)  do |i|
			#puts "indexing #{i}"
			@index << { :id=>i.to_s,:filename =>i.to_s, :category =>category, :text => IO.readlines(@dir+"/"+category+"/"+i.to_s) }	
			
		end
			
		@indexed = true		

	end
	
	
	def write_vects
		puts "Number of features #{@index.reader.all_terms.size}\n"
		if !@indexed then raise "Can write vects on an un-indexed dataset" end
		
		outfile1 = File.new(@idx_name+".vec", "w")

		puts "MaxDocs #{@index.reader.max_doc}\n"
		
		0.upto(@index.reader.max_doc-1)  do |i|	
			doc = DocumentInfo.new(i,@index.reader)
			outfile1.write(doc.full_s+"\n");			
			
		end
		outfile1.close
	
			
	end

	def write_vects_category(category_desc)
		@index.search_each('category:#{category_desc}') do |id, score|
		    puts "Document #{id} found with a score of #{score}"
	  	end

	end
end
