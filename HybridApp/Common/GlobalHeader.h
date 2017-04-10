//
//  GlobalHeader.h
//  HybridApp
//
//  Created by Joseph_iMac on 2017. 2. 18..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#define WIDTH_FRAME             [[UIScreen mainScreen] bounds].size.width
#define HEIGHT_FRAME            [[UIScreen mainScreen] bounds].size.height

// URL
#define TOKEN_URL               @"http://snap40.cafe24.com/Hybrid/hybrid_register.php"

// NSUserDefaults
#define TOKEN_KEY               @"token_key"
#define TOKEN_WEB_URL           @"token_url"

// 로딩바 히든 & 3초 딜레이 후 
#define LOADINGBAR_HIDDEN       @"loadingbar_hidden"
#define LOADINGBAR_TIME         @"loadingbar_time"

// 하단 버튼 메뉴바
#define BOTTOM_BUTTON_HIDDEN    @"bottom_button_hidden"
#define BOTTOM_BUTTON_COLOR     @"bottom_button_color"

// 하단 웹뷰 메뉴바
#define BOTTOM_WEBVIEW_HIDDEN   @"bottom_webview_hidden"
#define BOTTOM_WEBVIEW_COLOR    @"bottom_webview_color"

// 슬라이드 메뉴바 색깔
#define SLIDE_MENU_COLOR        @"slide_menu_color"

// 앱 화면이동 TRUE & FALSE & URL & 타이틀 & 버튼타이틀 & 버튼URL
#define SLIDE_MOVE              @"slide_move"
#define SLIDE_MOVE_URL          @"slide_move_url"
#define SLIDE_MOVE_TITLE        @"slide_move_title"
#define SLIDE_MOVE_BUTTON_TITLE @"slide_move_button_title"
#define SLIDE_MOVE_BUTTON_URL   @"slide_move_button_url"

// GPS ON - OFF
#define GPS_ON_OFF              @"ON"

// 인터넷 체크(웹 URL) ON - OFF
#define INTERNET_ON_OFF         @"ON"

// 메모리
#define TOKEN_CHECK1            [GlobalObject sharedInstance].tokenCheck1
#define TOKEN_CHECK2            [GlobalObject sharedInstance].tokenCheck2
#define MENU_IMAGE_SPLIT        [GlobalObject sharedInstance].menuImageSplit

