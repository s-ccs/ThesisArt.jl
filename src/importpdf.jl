function getPDFText(src;pages=nothing)
    # handle that can be used for subsequence operations on the document.
    doc = pdDocOpen(src)
    
    # Metadata extracted from the PDF document. 
    # This value is retained and returned as the return from the function. 
    docinfo = pdDocGetInfo(doc) 
    io = IOBuffer()
    
	# Returns number of pages in ithe document       
	#
	if isnothing(pages)

	pages = 1:pdDocGetPageCount(doc)
	end
	for i=pages
		@info "processing page $i"	
		# handle to the specific page given the number index. 
		page = pdDocGetPage(doc, i)
		
		# Extract text from the page and write it to the output file.
		pdPageExtractText(io, page)

	end
    
    # Close the document handle. 
    # The doc handle should not be used after this call
    pdDocClose(doc)
    return io
end

function import_pdf(filename;kwargs...)
io_txt = getPDFText(filename;kwargs...)
 txt = String(take!(io_txt))
	# remove tabstops
txt = replace(txt,"\t"=>" ");
txt = replace(txt,"\n"=>" ");
#txt = replace(txt,"ô"=>"o");
#txt = replace(txt,"é"=>"e")

for k = 1:10
	txt = replace(txt,"  "=>" ");
end
	# had some trouble with non-ascii characters. we will just remove them and hope nobody notice
	
txt = replace(txt, r"[^a-zA-Z0-9_ äöüéô]" => "");
return txt
end
