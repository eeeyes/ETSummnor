var cgfloat_encode = CGFloatEncode();

var cgrect_encode = "{x={y=" + cgfloat_encode + cgfloat_encode +"}"+"{y="+cgfloat_encode+cgfloat_encode+"}}";

var view_class = callCFunction("NSClassFromString","#@",["UIView"]);

var view = callObjcFunction("alloc","@@:",[view_class]);

view = callObjcFunction("init","@@:",[view]);

var frame = packValues([1,2,3,4],cgrect_encode);

callObjcFunction("setFrame:","v@:"+cgrect_encode,[view,frame]);

callCVarFunction("NSLog","v@@",1,["%@","HELLO WORLD FROM JS"]);

var width = unpackValue(frame,2);

callCVarFunction("NSLog","v@@",1,["width in js is %@",width]);