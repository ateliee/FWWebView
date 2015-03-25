//
//  WebView.h
//  frameworks
//
//  Created by ateliee on 2014/08/25.
//  Copyright (c) 2014年 minato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Helpers.h"

@protocol  FWWebViewCallback;

@interface FWWebView : UIWebView<UIWebViewDelegate,UIScrollViewDelegate>{
    // アクション時の呼び出しクラス
    id<FWWebViewCallback> callback;
    // 現在のリクエスト
    NSMutableURLRequest *requestData;
    NSString* nowURL;
    // JS呼び出しキー
    NSString *js_key;
    // タイムアウト
    int timeOut;
    // ユーザーエージェント
    NSString* userAgent;
    // JSからのメソッド呼び出し許可
    BOOL callMethodJSEnable;
    // 読み込み時にキャッシュクリアするか（デフォルトはYES）
    BOOL clearCacheLoading;
    // デフォルトのキャッシュポリシー
    NSURLRequestCachePolicy defaultCachePolicy;
    // 外部サイトをブラウザで開くか
    BOOL openURLBrowser;
    // Document読み込み完了
    BOOL documentLoaded;
}
@property(nonatomic,retain) id<FWWebViewCallback> callback;
@property(nonatomic) NSString* js_key;
@property(nonatomic) BOOL clearCacheLoading;
@property(nonatomic) NSURLRequestCachePolicy defaultCachePolicy;
@property(nonatomic) int timeOut;
@property(nonatomic) NSString* userAgent;
@property(nonatomic) BOOL callMethodJSEnable;
@property(nonatomic) BOOL openURLBrowser;
@property(nonatomic) BOOL documentLoaded;

// 現在のURL
-(NSString*) nowURL;
// ページの跳ね返りを禁止する
-(void)setDisableBounce;
// スクロールを禁止させる
-(void)setDisableScroll;
// スクロールの設定
-(void)setScrollHorizontal:(BOOL)enable;
-(void)setScrollVertical:(BOOL)enable;
// ページの読み込み
-(void)load:(NSString *)url;
-(void)loadEX:(NSString *)url method:(NSString *)method data:(NSString *)data;
-(void)loadRequestEX:(NSURLRequest *)request;
// リロード
-(void) fresh;
// サーバー側のURLかチェック
+(BOOL)isServerURL:(NSString *)url;
// ページの読み込み(URL)
//-(void)LoadURLRequest:(NSString *)url;
// ページの読み込み(ローカルファイル)
//-(void)LoadResourceRequest:(NSString *)url;
// htmlデータを取得する
-(NSString *)getHTMLString;
// 画面をクリア
-(void)blank;
// アプリケーションリンクか調べる
-(BOOL)isApplicationURL:(NSString *)url;

@end

// プロトコル宣言
@protocol FWWebViewCallback <NSObject>
@optional
// リクエストヘッダーのカスタマイズ
-(void) callWebViewCustomHeader : (FWWebView *)webView request:(NSMutableURLRequest*) request;
// 読み込み開始時のデリゲート
-(BOOL) callWebViewStartLoadWithRequest:(FWWebView *)webView request:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
// メソッドのコール(JSからのコール)
-(BOOL) callWebViewMethodJS : (FWWebView *)view method:(NSString *)method param:(NSObject*)params;
// ページクリック時のメソッド
-(BOOL) bindWebViewClickURL : (FWWebView *)webView request:(NSURLRequest *)request;
// ページ読み込み時のメソッド
-(BOOL) callWebViewRequestURL : (FWWebView *)webView request:(NSURLRequest *)request;
// DOMのonload時に呼ばれる
-(void) callWebViewOnLoaded : (FWWebView *)webView;
// DOMのonload失敗時に呼ばれる
-(void) callWebViewFailOnLoaded : (FWWebView *)webView;
// HTML読み込み成功時に呼ばれる
-(void) callWebViewDidFinishLoad:(FWWebView *)webView;
// HTMLステータスコードを取得
-(BOOL) callWebViewDidRequestStatus:(FWWebView *)webView status:(long)status;
// HTML読み込み失敗時に呼ばれる
-(void) callWebViewDidFailLoadWithError:(FWWebView *)webView error:(NSError *)error;
@end