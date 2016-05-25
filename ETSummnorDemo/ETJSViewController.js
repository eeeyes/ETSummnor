
function viewDidLoad(self_obj,method_cmd)
{
    callCVarFunction("NSLog","v@@",1,["%@","view controller in js"]);
    
    //
    
    root_view = callObjcFunction("view","@@:",[self_obj]);
    
    color_class = callCFunction("NSClassFromString","#@",["UIColor"]);
    
    green_color = callObjcFunction("greenColor","@@:",[color_class]);
    
    callObjcFunction("setBackgroundColor:","v@:@",[root_view,green_color]);
    
    // set nav title
    
    nav_item = callObjcFunction("navigationItem","@@:",[self_obj]);
    
    callObjcFunction("setTitle:","v@:@",[nav_item,"JS"]);
    
    
    tableview_class = callCFunction("NSClassFromString","#@",["UITableView"]);
    
    tableview = callObjcFunction("alloc","@@:",[tableview_class]);
    
    root_view_bounds = callObjcFunction("bounds","{x={y=dd}{y=dd}}@:",[root_view]);
    
    tableview = callObjcFunction("initWithFrame:","@@:{x={y=dd}{y=dd}}",[tableview,root_view_bounds]);
    
    callObjcFunction("addSubview:","v@:@",[root_view,tableview]);
    
    callObjcFunction("setDataSource:","v@:@",[tableview,self_obj]);
    
    callObjcFunction("setDelegate:","v@:@",[tableview,self_obj]);
}

function numberOfRowsInSection(self_obj,method_sel,tableview,section)
{
    return 100;
}

function numberOfSectionsInTableView(self_obj,method_sel,tableview)
{
    return 2;
}

function heightForRowAtIndexPath(self_obj,method_sel,tableview,indexpath)
{
    return 80;
}

function cellForRowAtIndexPath(self_obj,method_sel,tableview,indexpath)
{
    cellid = "test";
    
    row_number = callObjcFunction("row","l@:",[indexpath]);
    
    section_number = callObjcFunction("section","l@:",[indexpath]);
    
    cell_content = "" + row_number + "===" + section_number;

    cell = callObjcFunction("dequeueReusableCellWithIdentifier:","@@:@",[tableview,cellid]);
    
    if(isNull(cell)){
        
        cell_class = callCFunction("NSClassFromString","#@",["UITableViewCell"]);
        
        cell = callObjcFunction("alloc","@@:",[cell_class]);
        
        cell = callObjcFunction("initWithStyle:reuseIdentifier:","@@:l@",[cell,0,cellid]);
        
    }
    
    text_label = callObjcFunction("textLabel","@@:",[cell]);
    
    callObjcFunction("setText:","v@:@",[text_label,cell_content]);
    
    return cell;
}

function didSelectRowAtIndexPath(self_obj,method_sel,tableview,indexpath)
{
    nav_controller = callObjcFunction("navigationController","@@:",[self_obj]);
    
    view_controller_class = callCFunction("NSClassFromString","#@",["ETJSViewController"]);
    
    view_controller = callObjcFunction("alloc","@@:",[view_controller_class]);
    
    view_controller = callObjcFunction("init","@@:",[view_controller]);
    
    callObjcFunction("pushViewController:animated:","v@:@B",[nav_controller,view_controller,1]);
}

class_define = {"class_name":"ETJSViewController","super_class_name":"UIViewController",
    
    "funcs":[
        
             {
                "method_name" : "viewDidLoad" ,
             
                "method_encode" : "v@:",
             
                "method_imp" : "viewDidLoad"
             },
             
             {
                "method_name" : "tableView:numberOfRowsInSection:" ,
             
                "method_encode" :  "l@:@l",
             
                "method_imp"    :   "numberOfRowsInSection"
             },
             
             {
                "method_name" : "numberOfSectionsInTableView:" ,
             
                "method_encode" :  "l@:@",
             
                "method_imp"    :   "numberOfSectionsInTableView"
             },
             
             {
                "method_name" : "tableView:cellForRowAtIndexPath:" ,
             
                "method_encode" :  "@@:@@",
             
                "method_imp"    :   "cellForRowAtIndexPath"
             },
             
             {
                "method_name" : "tableView:heightForRowAtIndexPath:" ,
             
                "method_encode" :  "d@:@@",
             
                "method_imp"    :   "heightForRowAtIndexPath"
             },
             
             {
                "method_name" : "tableView:didSelectRowAtIndexPath:" ,
             
                "method_encode" :  "v@:@@",
             
                "method_imp"    :   "didSelectRowAtIndexPath"
             },


        
    ]
};

view_controller_class = registerClass(class_define);

view_controller = callObjcFunction("newObj","@@:",[view_controller_class]);

//create navigation controller

nav_controller_class = callCFunction("NSClassFromString","#@",["UINavigationController"]);

nav_controller = callObjcFunction("alloc","@@:",[nav_controller_class]);

nav_controller = callObjcFunction("initWithRootViewController:","@@:@",[nav_controller,view_controller]);

root_view_controller = nav_controller;