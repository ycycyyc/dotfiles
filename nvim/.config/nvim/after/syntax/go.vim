if exists('g:custom_define_highlight')

	let go_highlight_operators = 0
	let go_highlight_functions = 1
	let go_highlight_methods = 1
	let go_highlight_structs = 1

    " Comments; their contents
    " syn keyword     goTodo              contained NOTE
    " hi def link     goTodo              Todo


    " syn keyword     goBuiltins                 append cap close complex copy delete imag len
    " syn keyword     goBuiltins                 make new panic
    " hi goBuiltins ctermfg=170

    " Operators; 
    if go_highlight_operators != 0
        syn match goOperator /:=/
        syn match goOperator />=/
        syn match goOperator /<=/
        syn match goOperator /==/
        syn match goOperator /\s>\s/
        syn match goOperator /\s<\s/
        syn match goOperator /\s+\s/
        syn match goOperator /\s-\s/
        syn match goOperator /\s\*\s/
        syn match goOperator /\s\/\s/
        syn match goOperator /\s%\s/
    endif
    hi def link     goOperator         Operator

    " Functions; 
    " if go_highlight_functions != 0
    " 	syn match goFunction 	 		/\(func\s\+\)\@<=\w\+\((\)\@=/
    " 	syn match goFunction 	 		/\()\s\+\)\@<=\w\+\((\)\@=/
    " endif
    " hi def link     goFunction         Function

    " Methods; 
    if go_highlight_methods != 0
        " syn match goMethod 	 /\(\.\)\@<=\w\+\((\)\@=/
        syn match goMethod   /\w\+\ze\%(\[\%(\%(\[]\)\?\w\+\(,\s*\)\?\)\+\]\)\?(/
    endif

    hi def link     goMethod         Function

    " Structs; 
    if go_highlight_structs != 0
        syn match goStruct 	 			/\(.\)\@<=\w\+\({\)\@=/
        syn match goStructDef 	 	/\(type\s\+\)\@<=\w\+\(\s\+struct\s\+{\)\@=/
    endif
    hi def link     goStruct         Type
    hi def link     goStructDef         Type
endif
