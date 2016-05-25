function sort_array(a,b)
{
    int_method = "intValue";
    
    int_a = getObj(a);
    
    int_b = getObj(b);
    
    //callCVarFunction("NSLog","v@ii",1,["sort get %d %d",int_a,int_b]);
    
    if( int_a < int_b){
        
        return -1;
        
    }
    
    if( int_a > int_b ){
        
        return 1;
    }
    
    return 0;
}



var js_block =  newBlock(NSIntegerEncode()+"^v@@",sort_array);

var numbers = [4,2,8,1,10];

var sorted_numbers = getObj(callObjcFunction("sortedArrayUsingComparator:","@@:@?",[numbers,js_block]));


for (var i = 0; i < sorted_numbers.length; i++) {
    
    callCVarFunction("NSLog","v@i",1,["%d",sorted_numbers[i]]);
    
}