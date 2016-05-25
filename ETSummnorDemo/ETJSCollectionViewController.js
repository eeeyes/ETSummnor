var cgfloat_encode = CGFloatEncode();

var cgsize_encode = "{y=" + cgfloat_encode + cgfloat_encode +"}";

var cgrect_encode = "{x="+cgsize_encode+cgsize_encode+"}";

function viewDidLoad(self_obj,method_cmd)
{
    callCVarFunction("NSLog","v@@",1,["%@","view controller in js"]);
    
    //
    
    var root_view = callObjcFunction("view","@@:",[self_obj]);
    
    var color_class = callCFunction("NSClassFromString","#@",["UIColor"]);
    
    var green_color = callObjcFunction("blueColor","@@:",[color_class]);
    
    callObjcFunction("setBackgroundColor:","v@:@",[root_view,green_color]);
    
    // set nav title
    
    var nav_item = callObjcFunction("navigationItem","@@:",[self_obj]);
    
    callObjcFunction("setTitle:","v@:@",[nav_item,"TEST"]);
    
    //flow layout
    
    var flow_layout_class = callCFunction("NSClassFromString","#@",["UICollectionViewFlowLayout"]);
    
    var flow_layout = callObjcFunction("alloc","@@:",[flow_layout_class]);
    
    flow_layout = callObjcFunction("init","@@:",[flow_layout]);
    
    //collection view
    
    var collection_view_class =  callCFunction("NSClassFromString","#@",["UICollectionView"]);
    
    collection_view = callObjcFunction("alloc","@@:",[collection_view_class]);
    
    var root_view_bounds = callObjcFunction("bounds",cgrect_encode+"@:",[root_view]);
    
    collection_view = callObjcFunction("initWithFrame:collectionViewLayout:","@@:"+cgrect_encode+"@",[collection_view,root_view_bounds,flow_layout]);
    
    var white_color = callObjcFunction("whiteColor","@@:",[color_class]);
    
    callObjcFunction("setBackgroundColor:","v@:@",[collection_view,white_color]);
    
    var collection_reusable_view_class = callCFunction("NSClassFromString","#@",["UICollectionReusableView"]);
    
    var cell_class = callCFunction("NSClassFromString","#@",["ETJSCollectionViewCell"])
    
    callObjcFunction("registerClass:forCellWithReuseIdentifier:","v@:@@",[collection_view,cell_class,"cell"]);
    
    callObjcFunction("registerClass:forSupplementaryViewOfKind:withReuseIdentifier:","v@:@@@",[collection_view,collection_reusable_view_class,"UICollectionElementKindSectionHeader","reusableView"]);
    
    callObjcFunction("addSubview:","v@:@",[root_view,collection_view]);
    
    callObjcFunction("setDelegate:","v@:@",[collection_view,self_obj]);
    
    callObjcFunction("setDataSource:","v@:@",[collection_view,self_obj]);
}

function numberOfItemsInSection(self_obj,method_cmd)
{
    return 1000;
}

function cellForItemAtIndexPath(self_obj,method_cmd,collection_view,index_path)
{
    var cell = callObjcFunction("dequeueReusableCellWithReuseIdentifier:forIndexPath:","@@:@@",[collection_view,"cell",index_path]);
    
    var property_dict = getPropertyDict(cell);
    
    var label = callObjcFunction("objectForKey:","@@:@",[property_dict,"textLabel"]);
    
    callObjcFunction("setText:","v@:@",[label,"519"]);
    
    return cell;
}

function minimumLineSpacingForSectionAtIndex(self_obj,method_cmd,collection_view,layout,index_path)
{
    return 0;
}
function minimumInteritemSpacingForSectionAtIndex(self_obj,method_cmd,collection_view,layout,index_path)
{
    return 0;
}
function sizeForItemAtIndexPath(self_obj,method_cmd,collection_view,layout,index_path)
{
   // callCVarFunction("NSLog","v@@",1,["%@","xxx"]);
    
    var height = 80;
    
    var bounds = callObjcFunction("bounds",cgrect_encode+"@:",[collection_view]);
    
    var width = unpackValue(bounds,2)/3;
    
   // callCVarFunction("NSLog","v@i",1,["%d",width]);
    
    var size = packValues([width,height],cgsize_encode);
    
    
    
    return size;
}
//
function cellInitWithFrame(self_obj,method_cmd,frame)
{
    color_class = callCFunction("NSClassFromString","#@",["UIColor"]);
    
    label_class = callCFunction("NSClassFromString","#@",["UILabel"]);
    
    label = callObjcFunction("alloc","@@:",[label_class]);
    
    label = callObjcFunction("init","@@:",[label]);
    
    view_class = callCFunction("NSClassFromString","#@",["UIView"]);
    
    bottom_border = callObjcFunction("alloc","@@:",[view_class]);
    
    bottom_border = callObjcFunction("init","@@:",[bottom_border]);
    
    alpha_gray_color = callObjcFunction("grayColor","@@:",[color_class]);
    
    alpha_gray_color = callObjcFunction("colorWithAlphaComponent:","@@:d",[alpha_gray_color,0.2]);
    
    callObjcFunction("setBackgroundColor:","v@:@",[bottom_border,alpha_gray_color]);
    
    right_border = callObjcFunction("alloc","@@:",[view_class]);
    
    right_border = callObjcFunction("init","@@:",[right_border]);
    
    callObjcFunction("setBackgroundColor:","v@:@",[right_border,alpha_gray_color]);
    
    
    //right_border = callObjcFunction("")
    
    callObjcFunction("setTextAlignment:","v@:"+NSIntegerEncode(),[label,1]);
    
    self_obj = callObjcSuperFunction("initWithFrame:","@@:"+cgrect_encode,[self_obj,frame]);
 
    callObjcFunction("addSubview:","v@:@",[self_obj,label]);
    
    property_dict = getPropertyDict(self_obj);
    
    callObjcFunction("setObject:forKey:","v@:@@",[property_dict,label,"textLabel"]);
    
    callObjcFunction("setObject:forKey:","v@:@@",[property_dict,bottom_border,"bottom_border"]);
    
    callObjcFunction("setObject:forKey:","v@:@@",[property_dict,right_border,"right_border"]);
    
//    green_color = callObjcFunction("greenColor","@@:",[color_class]);
    
    white_color = callObjcFunction("whiteColor","@@:",[color_class]);
//
//    callObjcFunction("setBackgroundColor:","v@:@",[self_obj,green_color]);
//    
    callObjcFunction("setBackgroundColor:","v@:@",[self_obj,white_color]);
    
    callObjcFunction("addSubview:","v@:@",[self_obj,bottom_border]);
    
    callObjcFunction("addSubview:","v@:@",[self_obj,right_border]);
    
    return self_obj;
}

function cellLayout(self_obj,method_cmd)
{
    callObjcSuperFunction("layoutSubviews","v@:",[self_obj]);
    
    var property_dict = getPropertyDict(self_obj);
    
    var label = callObjcFunction("objectForKey:","@@:@",[property_dict,"textLabel"]);
    
    var bounds = callObjcFunction("bounds",cgrect_encode+"@:",[self_obj]);
    
    var height = unpackValue(bounds,3);
    
    var width = unpackValue(bounds,2);
    
    var bottom_border_frame = packValues([0,height-1,width,1],cgrect_encode);
    
    var right_border_frame = packValues([width-1,0,1,height],cgrect_encode);
    
    callObjcFunction("setFrame:","v@:"+cgrect_encode,[label,bounds]);
    
    //callCVarFunction("NSLog","v@@",1,["%@",label]);
    
    var bottom_border = callObjcFunction("objectForKey:","@@:@",[property_dict,"bottom_border"]);
    
    var right_border = callObjcFunction("objectForKey:","@@:@",[property_dict,"right_border"]);
    
    callObjcFunction("setFrame:","v@:"+cgrect_encode,[bottom_border,bottom_border_frame]);
    
    callObjcFunction("setFrame:","v@:"+cgrect_encode,[right_border,right_border_frame]);
    
    //callCVarFunction("NSLog","v@@",1,["%@",bottom_border]);
    
}

var class_define = {"class_name":"ETJSCollectionViewController","super_class_name":"UIViewController",
    
    "funcs":[
             
             {
                "method_name" : "viewDidLoad" ,
             
                "method_encode" : "v@:",
             
                "method_imp" : "viewDidLoad"
             },
             {
                "method_name":"collectionView:numberOfItemsInSection:",
             
                "method_encode" : NSIntegerEncode()+"@:@"+NSIntegerEncode(),
             
                "method_imp":"numberOfItemsInSection"
             },
             {
                "method_name":"collectionView:cellForItemAtIndexPath:",
                "method_encode":"@@:@@",
                "method_imp":"cellForItemAtIndexPath"
             },
             
             {
                "method_name":"collectionView:layout:minimumLineSpacingForSectionAtIndex:",
                "method_encode":cgfloat_encode+"@:@@@",
                "method_imp":"minimumLineSpacingForSectionAtIndex"
             },
             {
                "method_name":"collectionView:layout:sizeForItemAtIndexPath:",
                "method_encode":cgsize_encode+"@:@@@",
                "method_imp":"sizeForItemAtIndexPath"
             },
             {
             "method_name":"collectionView:layout:minimumInteritemSpacingForSectionAtIndex:",
             "method_encode":cgfloat_encode+"@:@@@",
             "method_imp":"minimumInteritemSpacingForSectionAtIndex"
             }
             
             ]
};

var cell_class_define = {"class_name":"ETJSCollectionViewCell","super_class_name":"UICollectionViewCell",
    
    "funcs":[
    
            {
                "method_name" : "initWithFrame:",
             
                "method_encode" : "@@:"+cgrect_encode,
             
                "method_imp": "cellInitWithFrame"
            },
             {
             "method_name":"layoutSubviews",
             "method_encode":"v@:",
             "method_imp":"cellLayout"
             }
             
    
            ]
};

registerClass(cell_class_define);

var view_controller_class = registerClass(class_define);

var view_controller = callObjcFunction("newObj","@@:",[view_controller_class]);

view_controller = callObjcFunction("init","@@:",[view_controller]);

var nav_controller_class = callCFunction("NSClassFromString","#@",["UINavigationController"]);

var nav_controller = callObjcFunction("alloc","@@:",[nav_controller_class]);

nav_controller = callObjcFunction("initWithRootViewController:","@@:@",[nav_controller,view_controller]);

var root_view_controller = nav_controller;