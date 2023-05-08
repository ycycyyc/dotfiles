if exists('g:custom_define_highlight')
    " function
    syn match   cCustomParen    transparent "(" contains=cParen contains=cCppParen
    syn match   cCustomFunc     "\w\+\s*(\@="
    hi def link cCustomFunc  Function

    " class
    syn match   cCustomScope    "::"
    syn match   cCustomClass    "\w\+\s*::"
                \ contains=cCustomScope
    hi def link cCustomClass Type

    " 
    syn clear cppStructure
    syn match cCustomClassKey "\<class\>"
    hi def link cCustomClassKey cppStructure

    " Clear cppAccess entirely and redefine as matches
    syn clear cppAccess
    syn match cCustomAccessKey "\<public\>"
    hi def link cCustomAccessKey cppAccess

    " Match the parts of a class declaration
    syn match cCustomClassName "\<class\_s\+\w\+\>"
                \ contains=cCustomClassKey

    syn match cCustomClassName "\<public\_s\+\w\+\>"
                \ contains=cCustomAccessKey

    hi def link cCustomClassName Type

    " std namespace
    syntax keyword cppSTLnamespace std
    syntax keyword cppSTLnamespace boost
    hi def link cppSTLnamespace YcNameSpace

    syntax keyword cppSTLfunctional function unique_ptr shared_ptr
    hi def link cppSTLfunctional Type

    syntax keyword cppBuiltIn namespace template typename
    hi def link cppBuiltIn Keyword

endif
