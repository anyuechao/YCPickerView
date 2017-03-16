//
//  YCPickerView.m
//  YCPickerView
//
//  Created by DJnet on 2017/3/16.
//  Copyright © 2017年 CoderAn. All rights reserved.
//

#define ZHToobarHeight 40
#import "YCPickerView.h"

@interface YCPickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,copy)NSString *plistName;
@property(nonatomic,strong)NSArray *plistArray;
@property(nonatomic,assign)BOOL isLevelArray;
@property(nonatomic,assign)BOOL isLevelString;
@property(nonatomic,assign)BOOL isLevelDic;
@property(nonatomic,strong)NSDictionary *levelTwoDic;
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,assign)NSDate *defaulDate;
@property(nonatomic,assign)BOOL isHaveNavControler;
@property(nonatomic,assign)NSInteger pickeviewHeight;
@property(nonatomic,copy)NSString *resultString;
@property(nonatomic,strong)NSMutableArray *componentArray;
@property(nonatomic,strong)NSMutableArray *dicKeyArray;
@property(nonatomic,copy)NSMutableArray *state;
@property(nonatomic,copy)NSMutableArray *city;
@end

@implementation YCPickerView

/**
 *   初始化方法 initWithFrame
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpToolBar];
        
    }
    return self;
}

#pragma mark- =====================public method=====================

/**
 *    外部调用初始化通过plistName创建
 */
-(instancetype)initPickviewWithPlistName:(NSString *)plistName isHaveNavControler:(BOOL)isHaveNavControler{
    
    self=[super init];
    if (self) {
        _plistName=plistName;
        self.plistArray=[self getPlistArrayByplistName:plistName];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
        
    }
    return self;
}

/**
 *    外部调用初始化通过NSArray创建
 */
-(instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler{
    self=[super init];
    if (self) {
        self.plistArray=array;
        [self setArrayClass:array];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}

/**
 *  外部调用初始化通过时间创建一个DatePicker
 */
-(instancetype)initDatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode isHaveNavControler:(BOOL)isHaveNavControler{
    
    self=[super init];
    if (self) {
        _defaulDate=defaulDate;
        [self setUpDatePickerWithdatePickerMode:(UIDatePickerMode)datePickerMode];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}

#pragma mark- =====================private method=====================

/**
 *   获取文件名称
 */
-(NSArray *)getPlistArrayByplistName:(NSString *)plistName{
    
    NSString *path= [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSArray * array=[[NSArray alloc] initWithContentsOfFile:path];
    [self setArrayClass:array];
    return array;
}

-(void)setArrayClass:(NSArray *)array{
    _dicKeyArray=[[NSMutableArray alloc] init];
    for (id levelTwo in array) {
        
        if ([levelTwo isKindOfClass:[NSArray class]]) {
            _isLevelArray=YES;
            _isLevelString=NO;
            _isLevelDic=NO;
        }else if ([levelTwo isKindOfClass:[NSString class]]){
            _isLevelString=YES;
            _isLevelArray=NO;
            _isLevelDic=NO;
            
        }else if ([levelTwo isKindOfClass:[NSDictionary class]])
        {
            _isLevelDic=YES;
            _isLevelString=NO;
            _isLevelArray=NO;
            _levelTwoDic=levelTwo;
            [_dicKeyArray addObject:[_levelTwoDic allKeys] ];
        }
    }
}

/**
 *   设置 frame
 */
-(void)setFrameWith:(BOOL)isHaveNavControler{
    CGFloat toolViewX = 0;
    CGFloat toolViewH = _pickeviewHeight+ZHToobarHeight;
    CGFloat toolViewY ;
    if (isHaveNavControler) {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH-50;
    }else {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH;
    }
    CGFloat toolViewW = [UIScreen mainScreen].bounds.size.width;
    self.frame = CGRectMake(toolViewX, toolViewY, toolViewW, toolViewH);
}

/**
 *   初始化PickView
 */
-(void)setUpPickView{
    
    UIPickerView *pickView=[[UIPickerView alloc] init];
    pickView.backgroundColor=[UIColor lightGrayColor];
    _pickerView=pickView;
    pickView.delegate=self;
    pickView.dataSource=self;
    pickView.frame=CGRectMake(0, 0, pickView.frame.size.width, pickView.frame.size.height);
    _pickeviewHeight=pickView.frame.size.height;
    [self addSubview:pickView];
}

/**
 *   时间
 */
-(void)setUpDatePickerWithdatePickerMode:(UIDatePickerMode)datePickerMode{
    UIDatePicker *datePicker=[[UIDatePicker alloc] init];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    datePicker.datePickerMode = datePickerMode;
    datePicker.backgroundColor= self.pikerbackGroundColor ?: [UIColor lightGrayColor];
    if (_defaulDate) {
        [datePicker setDate:_defaulDate];
    }
    _datePicker=datePicker;
    datePicker.frame=CGRectMake(0, ZHToobarHeight, datePicker.frame.size.width, datePicker.frame.size.height);
    _pickeviewHeight=datePicker.frame.size.height;
    [self addSubview:datePicker];
}

/**
 *   创建ToolBar
 */
-(void)setUpToolBar{
    _toolbar=[self setToolbarStyle];
    
    [self addSubview:_toolbar];
}

/**
 *   设置Toolbar参数
 */
-(void)setToolbarWithPickViewFrame{
    
    [_toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    //设置left
    NSLayoutConstraint *left =[NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint  *height = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:ZHToobarHeight];
    //添加到对应参照控件上
    [self addConstraints:@[left,right,bottom]];
    [self addConstraint:height];
}

- (void)layoutSubviews {
    [self setToolbarWithPickViewFrame];
}


/**
 *   点击确定事件
 */
-(void)doneClick
{
    if (_pickerView) {
        
        if (_resultString) {
            
        }else{
            if (_isLevelString) {
                _resultString=[NSString stringWithFormat:@"%@",_plistArray[0]];
            }else if (_isLevelArray){
                _resultString=@"";
                for (int i=0; i<_plistArray.count;i++) {
                    _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][0]];
                }
            }else if (_isLevelDic){
                
                if (_state==nil) {
                    _state =_dicKeyArray[0][0];
                    NSDictionary *dicValueDic=_plistArray[0];
                    _city=[dicValueDic allValues][0][0];
                }
                if (_city==nil){
                    NSInteger cIndex = [_pickerView selectedRowInComponent:0];
                    NSDictionary *dicValueDic=_plistArray[cIndex];
                    _city=[dicValueDic allValues][0][0];
                    
                }
                _resultString=[NSString stringWithFormat:@"%@%@",_state,_city];
            }
        }
    }else if (_datePicker) {
        
        _resultString=[NSString stringWithFormat:@"%@",_datePicker.date];
    }
    if ([self.delegate respondsToSelector:@selector(toobarDonBtnHaveClick:resultString:)]) {
        [self.delegate toobarDonBtnHaveClick:self resultString:_resultString];
    }
    [self removeFromSuperview];
}

-(void)dealloc{
    
    //NSLog(@"销毁了");
}


#pragma mark- =====================UIPickerViewDataSourse=====================

/**
 *   返回组数 number of 'columns' to display.
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    NSInteger component;
    if (_isLevelArray) {
        //返回数组的数量为组数
        component=_plistArray.count;
    } else if (_isLevelString){
        //默认Array<String>为 1组
        component=1;
    }else if(_isLevelDic){
        //几组 PickerView  当前为两组
        component=[_levelTwoDic allKeys].count*2;
    }
    return component;
}

/**
 *   返回每一组component 的数量return rows in each component
 */
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *rowArray=[[NSArray alloc] init];
    if (_isLevelArray) {
        rowArray=_plistArray[component];
    }else if (_isLevelString){
        rowArray=_plistArray;
    }else if (_isLevelDic){
        
        //选择component中的第一个并返回当前的 row
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        
        //根据 row 获取字典
        NSDictionary *dic=_plistArray[pIndex];
        for (id dicValue in [dic allValues]) {
            if ([dicValue isKindOfClass:[NSArray class]]) {
                
                //如果是第一组 component == 1
                if (component%2==1) {
                    //返回 政治中心 数量
                    
                    rowArray=dicValue;
                }else{
                    //返回 政治中心 对应 城市 的数量
                    
                    rowArray=_plistArray;
                }
            }
        }
    }
    return rowArray.count;
}

#pragma mark- =====================UIPickerViewdelegate=====================
/**
 *   类似于 tableView代理方法 CellforRowAtIndex 方法,根据component组数返回相应的row
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *rowTitle=nil;
    if (_isLevelArray) {
        rowTitle=_plistArray[component][row];
    }else if (_isLevelString){
        rowTitle=_plistArray[row];
    }else if (_isLevelDic){
        //        默认 row
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic=_plistArray[pIndex];
        if(component%2==0)
        {
            rowTitle=_dicKeyArray[row][component];
        }
        for (id aa in [dic allValues]) {
            if ([aa isKindOfClass:[NSArray class]]&&component%2==1){
                NSArray *bb=aa;
                if (bb.count>row) {
                    rowTitle=aa[row];
                }
                
            }
        }
    }
    
    
    
    return rowTitle;
}

/**
 *   pickerView点击事件
 */
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (_isLevelDic&&component%2==0) {
        
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
    if (_isLevelString) {
        _resultString=_plistArray[row];
        
    }else if (_isLevelArray){
        _resultString=@"";
        if (![self.componentArray containsObject:@(component)]) {
            [self.componentArray addObject:@(component)];
        }
        for (int i=0; i<_plistArray.count;i++) {
            if ([self.componentArray containsObject:@(i)]) {
                NSInteger cIndex = [pickerView selectedRowInComponent:i];
                _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][cIndex]];
            }else{
                _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][0]];
            }
        }
    }else if (_isLevelDic){
        if (component==0) {
            _state =_dicKeyArray[row][0];
        }else{
            NSInteger cIndex = [pickerView selectedRowInComponent:0];
            NSDictionary *dicValueDic=_plistArray[cIndex];
            NSArray *dicValueArray=[dicValueDic allValues][0];
            if (dicValueArray.count>row) {
                _city =dicValueArray[row];
            }
        }
    }
}


#pragma mark- =====================public method=====================
/**
 *   移除本控件
 */
-(void)remove{
    
    [self removeFromSuperview];
}

/**
 *  显示本控件
 */
-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
}

#pragma mark- =====================setter method=====================
/**
 *  设置PickView的颜色
 */
-(void)setPickViewColer:(UIColor *)color{
    _pickerView.backgroundColor=color;
}
/**
 *  设置toobar的文字颜色
 */
-(void)setTintColor:(UIColor *)color{
    
    _toolbar.tintColor=color;
}
/**
 *  设置toobar的背景颜色
 */
-(void)setToolbarTintColor:(UIColor *)color{
    
    _toolbar.barTintColor=color;
}

#pragma mark- =====================getter method=====================

-(NSArray *)plistArray{
    if (_plistArray==nil) {
        _plistArray=[[NSArray alloc] init];
    }
    return _plistArray;
}

-(NSArray *)componentArray{
    
    if (_componentArray==nil) {
        _componentArray=[[NSMutableArray alloc] init];
    }
    return _componentArray;
}

-(UIToolbar *)setToolbarStyle{
    UIToolbar *toolbar=[[UIToolbar alloc] init];
    
    UIButton *toolbarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolbarBtn.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ZHToobarHeight);
    [toolbarBtn setTitle:@"确定" forState:UIControlStateNormal];
    [toolbarBtn setBackgroundColor:[UIColor greenColor]];
    [toolbarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [toolbarBtn addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    
    [toolbar addSubview:toolbarBtn];
    
    return toolbar;
}




@end
