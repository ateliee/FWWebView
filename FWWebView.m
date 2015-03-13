//
//  FWWebView.m
//  frameworks
//
//  Created by ateliee on 2014/08/25.
//  Copyright (c) 2014年 minato. All rights reserved.
//

#import "FWWebView.h"

@interface FWWebView(){
    // 呼び出し回数をカウント
    int retainCount;
    // コネクションクラス
    NSURLConnection *Connection;
    NSMutableData *ConnectionData;
    // POST,GETデータを格納しておく
    NSMutableDictionary *POST;
    NSMutableDictionary *GET;
    NSMutableDictionary *REQUEST;
    
    NSTimer *loadedTimer;
    NSDate *loadStartDate;
    
    // scrollViewの不具合対策用
    BOOL showKeyboard;
    BOOL pauseScroll;
    CGPoint scrollOrigin;
    CGPoint defaultScrollOrigin;
}
// 初期化
-(void) initalization;
@end

@implementation FWWebView

#define FWWEBVIEW_ONLOADFUNCNAME (@"iosOnLoad")

@synthesize js_key;
@synthesize callback;
@synthesize callMethodJSEnable;
@synthesize timeOut;
@synthesize clearCacheLoading;
@synthesize defaultCachePolicy;
@synthesize openURLBrowser;
@synthesize documentLoaded;

-(NSString*)nowURL{
    return [nowURL copy];
}
-(void) dealloc{
    self.delegate = nil;
}
// 初期化
-(void) initalization{
    // JS → Object-C用
    self.js_key = @"XCODE-API://";
    self.callMethodJSEnable = YES;
    self.clearCacheLoading = YES;
    self.defaultCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    self.openURLBrowser = YES;
    // デリゲートを指定
    self.delegate = self;
    // 跳ね返り時の影を削除
    for (UIView* wview in [[[self subviews] objectAtIndex:0]subviews]) {
        if([wview isKindOfClass:[UIImageView class]]){
            wview.hidden = YES;
        }
    }
    // 背景を透明化
    [self setTransparentBackground];
    // タイムアウト設定
    self.timeOut = 10;
    loadedTimer = nil;
    
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}
-(void) keyboardWillShow{
    if (!showKeyboard) {
        defaultScrollOrigin = self.scrollView.contentOffset;
    }
    showKeyboard = YES;
}
-(void) keyboardDidShow{
    //pauseScroll = NO;
    pauseScroll = YES;
}
-(void) keyboardWillHide{
    pauseScroll = NO;
    showKeyboard = NO;
    [self.scrollView setContentOffset:defaultScrollOrigin animated:YES];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (showKeyboard) {
        if (pauseScroll) {
            [self.scrollView setContentOffset:scrollOrigin animated:NO];
        }else{
            scrollOrigin = self.scrollView.contentOffset;
            pauseScroll = YES;
        }
    }
}
-(id)init{
    self = [super init];
    if (self) {
        // Initialization code
        [self initalization];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initalization];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        // デリゲートを指定
        [self initalization];
    }
    return self;
}
// 背景を透明化
-(void)setTransparentBackground{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
}
// ページの跳ね返りを禁止する
-(void)setDisableBounce{
    for(id subview in self.subviews){
        if([[subview class]isSubclassOfClass:[UIScrollView class]]){
            ((UIScrollView *)subview).bounces = NO;
            ((UIScrollView *)subview).scrollEnabled = YES;
            ((UIScrollView *)subview).minimumZoomScale = 1.0f;
            ((UIScrollView *)subview).bouncesZoom = NO;
            ((UIScrollView *)subview).alwaysBounceVertical = NO;
            ((UIScrollView *)subview).alwaysBounceHorizontal = NO;
        }
    }
}
// スクロールを禁止させる
-(void)setDisableScroll{
    for(id subview in self.subviews){
        if([[subview class]isSubclassOfClass:[UIScrollView class]]){
            ((UIScrollView *)subview).bounces = NO;
            ((UIScrollView *)subview).scrollEnabled = NO;
        }
    }
}
// スクロールの設定
-(void)setScrollHorizontal:(BOOL)enable{
    self.scrollView.showsHorizontalScrollIndicator = enable;
}
-(void)setScrollVertical:(BOOL)enable{
    self.scrollView.showsVerticalScrollIndicator = enable;
}
/*// スクロールデリゲート
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //scrollView.bounds = webView.bounds;
    if (pauseScroll) {
        NSLog(@"%f,%f",scrollView.contentOffset.x,scrollView.contentOffset.y);
        [scrollView setContentOffset:scrollOrigin animated:NO];
    }
    // 水平スクロール制御
    if(!self.scrollView.showsHorizontalScrollIndicator){
        CGPoint origin = [scrollView contentOffset];
        [scrollView setContentOffset:CGPointMake(0.0,origin.y)];
    }
    // 垂直スクロール制御
    if(!self.scrollView.showsVerticalScrollIndicator){
        CGPoint origin = [scrollView contentOffset];
        [scrollView setContentOffset:CGPointMake(origin.x, 0.0)];
    }
}*/
// ページの読み込み
-(void)load:(NSString *)url{
    [self loadEX:url method:@"GET" data:nil];
}
// ページの読み込み(拡張版)
-(void)loadEX:(NSString *)url method:(NSString *)method data:(NSString *)data{
    // リクエスト
    NSString *request_url = [[NSString alloc]initWithString:url];
    NSMutableURLRequest *request;
    // POST送信
    if([method isEqualToString:@"POST"]){
        // URLの作成
        NSString *rurl = [request_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        request = [[NSMutableURLRequest alloc]initWithURL:[self.class makeURL:rurl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.timeOut];
        // METHOD設定
        [request setHTTPMethod: method];
        // BODY
        if(data != nil){
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // GET送信
    }else{
        if(data && ![data isEqualToString:@""]){
            request_url = [request_url stringByAppendingFormat:@"?%@",data];
        }
        NSString *rurl = request_url;
        // URLの作成
        request = [[NSMutableURLRequest alloc]initWithURL:[self.class makeURL:rurl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.timeOut];
    }
    [self loadRequestEX:request];
}

-(void)loadRequestEX:(NSURLRequest *)request{
    NSMutableURLRequest *req = [request mutableCopy];
    
    if(self.clearCacheLoading){
        [req setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [self removeCache];
    }else{
        [req setCachePolicy:defaultCachePolicy];
    }
    // タイムアウト設定
    [req setTimeoutInterval:self.timeOut];
    [req setValue:[self stringByEvaluatingJavaScriptFromString:@"window.navigator.userAgent"] forHTTPHeaderField:@"User-Agent"];
    
    // カスタムヘッダー
    if(callback){
        if([callback respondsToSelector:@selector(callWebViewCustomHeader:request:)]){
            [callback callWebViewCustomHeader:self request:req];
        }
    }
    
    // リクエストされたURLを保存
    nowURL = nil;
    nowURL = [[req URL] relativeString];
    requestData = nil;
    requestData = req;
    documentLoaded = NO;
    loadStartDate = [NSDate date];
    // WEB上のHTMLの読み込み
    Connection = nil;
    ConnectionData = nil;
    NSString* request_url = nowURL;
    if (![self.class isServerURL:request_url]) {
        [super loadRequest:req];
        [self finishWebPage];
    }else{
        //NSLog(@"request : %@",request);
        // NSURLConnectionから読み込み
        Connection = [[NSURLConnection alloc]initWithRequest:req delegate:self startImmediately:YES];
        if (Connection) {
            ConnectionData = [[NSMutableData alloc] init];
        }
    }
}
// キャッシュを削除し、再読み込み
-(void) fresh{
    // 現在のリクエストを保存
    NSMutableURLRequest* r = [requestData copy];
    NSURLRequestCachePolicy d = defaultCachePolicy;
    [r setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    // 一度ブランク
    [self blank];
    [self loadRequestEX:r];
    // キャッシュポリシーを戻す
    defaultCachePolicy = d;
}
// URLの作成
+(NSURL *)makeURL:(NSString *)url{
    NSURL *nsurl = nil;
    // サーバーファイル
    if([self isServerURL:url]){
        nsurl = [NSURL URLWithString:url];
    }else{
        nsurl = [NSURL fileURLWithPath:url];
    }
    return nsurl;
}
// サーバー側のURLかチェック
+(BOOL)isServerURL:(NSString *)url{
    // 読み込むURLを解析
    NSURL *pathinfo = [NSURL URLWithString:url];
    NSString *scheme = [pathinfo scheme];
    if(scheme){
        return TRUE;
    }
    return FALSE;
}

// キャッシュクリア
-(void) removeCache{
    // キャッシュ容量を０に変更
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    // キャッシュ削除
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    // キャッシュ削除
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    //[sharedCache release];
}

// HTML読み込み時に呼ばれる
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    // キャッシュファイルの削除
    if(self.clearCacheLoading){
        [self removeCache];
        // キャッシュポリシーの変更
        if(request.cachePolicy != NSURLRequestReloadIgnoringLocalAndRemoteCacheData){
            //NSMutableURLRequest *req = (NSMutableURLRequest *)request;
            //req.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        }
    }
    // iframe対策
    BOOL isFrame = ![[[request URL] absoluteString] isEqualToString:[[request mainDocumentURL] absoluteString]];
    if(!isFrame){
        // デリゲートメソッドを呼び出し
        if(callback && [callback respondsToSelector:@selector(callWebViewStartLoadWithRequest:request:navigationType:)]){
            return [callback callWebViewStartLoadWithRequest:self request:request navigationType:navigationType];
        }
    }
    NSString *urlStr = [[request URL] absoluteString];
    
    // POST,GETデータの初期化
    if (!isFrame) {
        REQUEST = nil;
        POST = nil;
        GET = nil;
        if(request.HTTPBody){
            NSMutableDictionary *request_data = [[[NSString alloc]initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] parseParam];
            if([request.HTTPMethod isEqualToString:@"POST"]){
                POST = request_data;
                NSArray* nk = [POST allKeys];
                for (NSString* k in nk) {
                    [POST setObject:[POST[k] stringByReplacingOccurrencesOfString:@"+" withString:@" "] forKey:k];
                }
            }else{
                GET = request_data;
            }
            //NSLog(@"%@",POST);
            REQUEST = [[NSMutableDictionary alloc]init];
            [REQUEST setDictionary: request_data];
        }
    }
    
    // キャッシュファイルをダンプ
    //dbgLog(@"currentDiskUsage : %d",[[NSURLCache sharedURLCache] currentDiskUsage]);
    //dbgLog(@"diskCapacity : %d",[[NSURLCache sharedURLCache] diskCapacity]);
    //dbgLog(@"currentMemoryUsage : %d",[[NSURLCache sharedURLCache] currentMemoryUsage]);
    //dbgLog(@"memoryCapacity : %d",[[NSURLCache sharedURLCache] memoryCapacity]);
    // Xcodeメソッドの呼び出し
    if(self.callMethodJSEnable){
        // URLからの呼び出し
        NSString *method = @"";
        NSObject *params = nil;
        
        if([urlStr hasPrefix:self.js_key]){
            //urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            urlStr = (__bridge NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)urlStr, CFSTR(""), kCFStringEncodingUTF8);
            //dbgLog(@"URL : %@",urlStr);
            urlStr = [urlStr stringByReplacingOccurrencesOfString:self.js_key withString:@""];
            NSError *error = nil;
            NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:@"^(\\S+?)\\((.*)\\)" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
            //NSLog(@"%@",urlStr);
            if(error == nil){
                NSTextCheckingResult *match = [regexp firstMatchInString:urlStr options:0 range:NSMakeRange(0, urlStr.length)];
                
                if(match.numberOfRanges != 0){
                    method = [urlStr substringWithRange:[match rangeAtIndex:1]];
                    NSString *paramsStr = [urlStr substringWithRange:[match rangeAtIndex:2]];
                    if(![paramsStr isEqualToString:@""]){
                        NSArray* pp = [paramsStr componentsSeparatedByString:@","];
                        NSMutableArray* p = [[NSMutableArray alloc] init];
                        NSString *tmp = @"";
                        for (NSString* s in pp) {
                            NSString* t = [NSString stringWithString:s];
                            if (![tmp isEqualToString:@""]) {
                                t = [NSString stringWithFormat:@"%@,%@",tmp,t];
                            }
                            BOOL dc = ([t hasPrefix:@"\""] && [t hasSuffix:@"\""]);
                            BOOL sc = ([t hasPrefix:@"'"] && [t hasSuffix:@"'"]);
                            if (dc || sc) {
                                t = [t substringWithRange:NSMakeRange(1, [t length] - 2)];
                                [p addObject:t];
                                tmp = @"";
                            }else if ([t hasPrefix:@"\""] || [t hasPrefix:@"'"]) {
                                tmp = t;
                            }else{
                                [p addObject:t];
                            }
                        }
                        if (![tmp isEqualToString:@""]) {
                            [p addObject:tmp];
                        }
                        params = [[NSArray alloc] initWithArray:p];
                    }
                }
            }
            // パラメータからの呼び出し
        }else if((!isFrame) && POST && [[POST allKeys]containsObject:self.js_key]){
            method = [POST objectForKey:self.js_key];
            NSMutableDictionary *p = [[NSMutableDictionary alloc] init];
            [p setDictionary:POST];
            [p removeObjectForKey:self.js_key];
            params = p;
        }
        if(![method isEqualToString:@""]){
            //dbgLog(@"call JS : function[%@] params[%@]",method,params);
            // メソッドのコール
            if(callback){
                // デリゲートメソッドを呼び出し
                if([callback respondsToSelector:@selector(callWebViewMethodJS:method:param:)]){
                    if([callback callWebViewMethodJS:self method:method param:params]){
                    }
                }
            }
            return NO;
        }
    }
    if (isFrame) {
        return YES;
    }
    // クリック時
    if(navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted){
        // リクエストからURL文字列取得
        NSString* url = [[request URL] relativeString];
        // 読み込みをハックする
        if(callback && [callback respondsToSelector:@selector(bindWebViewClickURL:request:)]){
            return [callback bindWebViewClickURL:self request:request];
        }
        // アプリケーションの起動
        if([self isApplicationURL:url]){
            [([UIApplication sharedApplication]) openURL:[NSURL URLWithString:url]];
        }
        // 外部サイトの場合、Safariを起動
        if(([url indexOf:@"http://"] == 0) || ([url indexOf:@"https://"] == 0)){
            if(self.openURLBrowser){
                [([UIApplication sharedApplication]) openURL:[NSURL URLWithString:url]];
                return NO;
            }
        }
        // ページ内リンクの場合はインジケーターを表示しない
        if([url indexOf:@"#"] >= 0){
            return YES;
        }
        // 読み込みをハックする
        if(callback && [callback respondsToSelector:@selector(callWebViewRequestURL:request:)]){
            return [callback callWebViewRequestURL:self request:request];
        }
    }
    retainCount ++;
    return YES;
}
// アプリケーションリンクか調べる
-(BOOL)isApplicationURL:(NSString *)url{
    
    // アプリケーションの起動
    if([url indexOf:@"mailto:"] == 0){
        return YES;
    // GoogleMap起動
    }else if([url indexOf:@"comgooglemaps:"] == 0){
        return YES;
    }
    return NO;
}

// HTML読み込み成功時に呼ばれる
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    retainCount --;
    // デリゲートメソッドを呼び出し
    if(retainCount == 0){
        [((FWWebView *)webView) finishWebPage];
    }
}
// HTML読み込み失敗時に呼ばれる
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    retainCount --;
    // デリゲートメソッドを呼び出し
    if(retainCount == 0){
        if(callback && [callback respondsToSelector:@selector(callWebViewDidFailLoadWithError:error:)]){
            [callback callWebViewDidFailLoadWithError:(FWWebView *)webView error:error];
        }
        // タイムアウト
        if(callback && [callback respondsToSelector:@selector(callWebViewFailOnLoaded:)]){
            [callback callWebViewFailOnLoaded:self];
        }
    }
}
// ページが読み込まれた直後
-(void)finishWebPage{
    // デリゲートメソッドの実行
    if(callback && [callback respondsToSelector:@selector(callWebViewDidFinishLoad:)]){
        [callback callWebViewDidFinishLoad:self];
    }
    // イベント追加
    NSString *js = @"if(%@Func == undefined){ function %@Func(){ window.%@=TRUE; } } window.%@=FALSE; "
    "if(typeof window.addEventListener != \"undefined\"){ window.addEventListener(\"load\",iosOnLoad,false); }"
    "else if(typeof window.attachEvent != \"undefined\")"
    "{ window.attachEvent(\"onload\",iosOnLoad); } ";
    js = [[NSString alloc] initWithFormat:js,FWWEBVIEW_ONLOADFUNCNAME,FWWEBVIEW_ONLOADFUNCNAME,FWWEBVIEW_ONLOADFUNCNAME,FWWEBVIEW_ONLOADFUNCNAME];
    [self stringByEvaluatingJavaScriptFromString:js];
    
    // タイマー設定
    if (loadedTimer) {
        [loadedTimer invalidate];
        loadedTimer = nil;
    }
    loadedTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(documentLoadedCheck) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:loadedTimer forMode:NSDefaultRunLoopMode];
}
// 読み込み完了をチェック
-(void)documentLoadedCheck{
    float tmp = [[NSDate date] timeIntervalSinceDate: loadStartDate];
    if ([self stringByEvaluatingJavaScriptFromString:[[NSString alloc] initWithFormat:@"window.%@",FWWEBVIEW_ONLOADFUNCNAME]]) {
        documentLoaded = YES;
        [loadedTimer invalidate];
        loadedTimer = nil;
        
        if(callback && [callback respondsToSelector:@selector(callWebViewOnLoaded:)]){
            [callback callWebViewOnLoaded:self];
        }
    }else if(tmp >= timeOut){
        // タイムアウト
        if(callback && [callback respondsToSelector:@selector(callWebViewFailOnLoaded:)]){
            [callback callWebViewFailOnLoaded:self];
        }
    }
}

// htmlデータを取得する
-(NSString *)getHTMLString{
    return [self stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML"];
}
// 画面をクリア
-(void)blank{
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:nlank"]]];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - NSURLConnection Delegate
// サーバーからのレスポンス受信(複数回呼ばれる可能性もあり)
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    BOOL error = NO;
    if([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSInteger status = [((NSHTTPURLResponse *)response) statusCode];
        if(callback && [callback respondsToSelector:@selector(callWebViewDidRequestStatus:status:)]){
            error = [callback callWebViewDidRequestStatus:self status:status];
        }else{
            // 400番代以上はエラー
            if (status >= 400) {
                error = YES;
            }
        }
    }
    if (error) {
        // エラー
        [Connection cancel];
        // 受信失敗
        [self connection:connection didFailWithError:nil];
    }else{
        [ConnectionData setLength:0];
    }
}
// データ受信時(データは少しずつ呼ばれる)
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [ConnectionData appendData:data];
}
// データ受信失敗
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Connection Error : %@",error);
    Connection = nil;
    ConnectionData = nil;
    // コネクションエラー
    if(callback && [callback respondsToSelector:@selector(callWebViewDidFailLoadWithError:error:)]){
        [callback callWebViewDidFailLoadWithError:self error:error];
    }
    // タイムアウト
    if(callback && [callback respondsToSelector:@selector(callWebViewFailOnLoaded:)]){
        [callback callWebViewFailOnLoaded:self];
    }
}
// データ受信完了時
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    // 読み込み完了時にHTMLをコピー
    NSString* url_str = [nowURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:url_str];
    [self loadData:ConnectionData MIMEType:@"text/html" textEncodingName:nil baseURL:url];
    Connection = nil;
    ConnectionData = nil;
    
    [self finishWebPage];
}
@end
