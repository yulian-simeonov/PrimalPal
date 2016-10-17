//
//  Macro.h
//  PrimalPal
//
//  Created by YulianMobile on 5/11/13.
//  Copyright (c) 2013 YulianMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EPdfTypeNewspaper,
    EPdfTypeMagazine,
} EPdfType;

#define SCRN_WIDTH		[[UIScreen mainScreen] bounds].size.width
#define SCRN_HEIGHT		[[UIScreen mainScreen] bounds].size.height
#define IS_PHONE5 SCRN_HEIGHT > 480 ? TRUE:FALSE
#define LOGO_COLOR      [UIColor colorWithRed:102/255.0f green:187/255.0f blue:112/255.0f alpha:0.6]
#define APPDELEGATE [PPAppDelegate sharedDelegate]

#define kTitle_APP      @"PrimalPal"

#define SERVER_URL  @"http://v2.primalpal.net"
#define AVATAR_URL  @"http://mysportalent.com/instagram/data/profile"

#define API_ACTIVATE_DEVICE     @"/api/devices/activate"
#define API_LOGIN               @"/api/user/login"
#define API_LOGOUT              @"/api/user/logout"

#define API_SIGNUP              @"/api/user/upsert"
#define API_ISPAID              @"/api/user/IsPaid"
#define API_SETPAID             @"/api/user/UpdatePayment?paid=1"

#define API_GETRECIPES          @"/api/recipes/search"
#define API_GETRECIPEDETAIL     @"/api/recipe"
#define API_CHECKINUPDATE       @"/api/paleopercent/update"
#define API_CHECKINGET          @"/api/paleopercent/get"
#define API_ADDFAV              @"/api/myrecipes/add"
#define API_DELFAV              @"/api/myrecipes/del"
#define API_GETMEALPLAN         @"/api/planner/getweek"
#define API_DELMEALPLAN         @"/api/planner/delete"
#define API_PLANMEAL            @"/api/planner/plan"
#define API_GETSHOPPINGLIST     @"/api/shoppinglist"
#define API_BUYSHOPPINGLIST     @"/api/shoppinglist/bought"
#define API_DELSHOPPINGLIST     @"/api/shoppinglist/del"
#define API_SETGOAL             @"/api/AddScopeValue"

// Notification
#define kNotiDidLoggedIn        @"DidLoggedIn"
#define kNotiLogout             @"LogOut"
#define kNotiShowLogin          @"ShowLogin"
#define kNotiFavChanged         @"FavChanged"
#define kNotiOpenRecipe         @"OpenRecipes"
#define kNotiLoggedIn           @"LoggedIn"

// Storyboard Identifier
#define kIdentifierLoginView            @"LoginVC"
#define kIdentifierCheckinView          @"CheckinVC"
#define kIdentifierRecipesView          @"RecipesVC"
#define kIdentifierMealplanView         @"MealplanVC"
#define kIdentifierFavouritesView       @"FavVC"
#define kIdentifierShoppinglistView     @"ShoppinglistVC"
#define kIdentifierSettingsView         @"SettingsVC"
#define kIdentifierDashboardView        @"DashboardVC"
#define kIdentifierSidemenuView         @"rightVC"
#define kIdentifierCenteralView         @"centerVC"

// Message
#define MESSAGE_FILLINTHEINPUTFIELD     @"Please fill in the input field"
#define MESSAGE_VALIDEMAIL              @"Email is not valid"
#define MESSAGE_AUTHFAILED              @"Authentication is failed"
#define MESSAGE_CONNECTIONFAILED        @"Connection is failed"
#define MESSAGE_LOGINFAILED             @"Login failed"
#define MESSAGE_SIGNUPSUCCESS           @"Successfully registered"
#define MESSAGE_PURCHASESUCCESS         @"Successfully purchased"

@interface Macro : NSObject

@end
