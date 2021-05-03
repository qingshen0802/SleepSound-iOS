//
//  StoreManager.h
//  7 Minute Workout
//
//  Created by Ditriol Wei on 2/7/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class MProduct;
@protocol StoreManagerDelegate;

@interface StoreManager : NSObject <SKPaymentTransactionObserver>
+ (StoreManager *)sharedInstance;
@property (assign, nonatomic) id<StoreManagerDelegate> delegate;

- (void)restore;
- (void)registerProducts:(NSArray *)products;//array of MProduct
- (void)buyProduct:(MProduct *)p;
@end

@protocol StoreManagerDelegate <NSObject>
@optional
- (void)storeManager:(StoreManager *)manager didReceiveInfoFor:(NSArray *)products;
- (void)storeManager:(StoreManager *)manager didPurchaseProduct:(MProduct *)p withSuccess:(BOOL)isSuccess;
- (void)storeManagerRestored:(StoreManager *)manager withSuccess:(BOOL)isSuccess;
- (void)storeManagerFinishedValidatingReceipt:(StoreManager *)manager withSuccess:(BOOL)isSuccess;
@end


@interface MProduct : NSObject
- (id)initWithProductId:(NSString *)Id;
- (void)save;
- (BOOL)isUsable;

@property (strong, nonatomic) NSString * productId;
@property (assign, nonatomic) BOOL isPuchased;
@property (strong, nonatomic) NSDate * expireDate;

@property (strong, nonatomic) SKProduct * product;
- (NSString *)price;
- (BOOL)isReceivedInfo;
@property (assign, nonatomic) BOOL isNeedToBuy;
@property (assign, nonatomic) BOOL isNeedValidatingReceipt;

@end