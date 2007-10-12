## indextest.rb
## TODO: Write get term vector hash
## TODO: create de class DataSet

require 'dataindexer.rb'


CATEGORY_STARTNUMBER = {"alt.atheism" => 51119,"comp.graphics"=> 37913}

dir = "20_newsgroups"
cat1 = "alt.atheism"
cat2 = "comp.graphics"

dsidx = DataSetIndexer.new(dir)
dsidx.create_index("datasets")
dsidx.index_category(cat1,CATEGORY_STARTNUMBER[cat1],50,"1")
dsidx.index_category(cat2,CATEGORY_STARTNUMBER[cat2],50,"-1")
dsidx.write_vects_category("alt.atheism")

  
#dsidx.index.search_each('text:"god"') do |id, score|
#     puts "Document #{id} found with a score of #{score}"
# end
 
#end

#te = index.reader.terms(:text)
#tv = index.reader.term_vector(14,:text)
#tv.terms.each {|t| puts "term #{t.text}  with  #{t.positions.size}" }
#puts Analysis::FULL_SPANISH_STOP_WORDS
#x = MiguelBiAnalyzer.new

#now for aeach document we find the words hash but sorted

#doc = DocumentInfo.new(1,dsidx.index.reader)

#puts doc.full_s
#dsidx.labels

#make it an inter function





