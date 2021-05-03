//
//  StoreManager.m
//  7 Minute Workout
//
//  Created by Ditriol Wei on 2/7/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "StoreManager.h"

#define kSharedSecret   @"c3aaedac4e814871b9e7213c48b00a6b"
#define kSandboxServer  @"https://sandbox.itunes.apple.com/verifyReceipt"
#define kLiveServer     @"https://buy.itunes.apple.com/verifyReceipt"

static NSDictionary *errorDictionary;

@interface StoreManager () <SKRequestDelegate, SKProductsRequestDelegate>
@property (strong, nonatomic) NSMutableDictionary * products;
@end

@implementation StoreManager

+ (StoreManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static StoreManager * storeManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        storeManagerSharedInstance = [[StoreManager alloc] init];
    });
    return storeManagerSharedInstance;
}

#pragma mark - Initializer
+ (void)initialize {
    errorDictionary = @{@(21000) : @"The App Store could not read the JSON object you provided.",
                        @(21002) : @"The data in the receipt-data property was malformed or missing.",
                        @(21003) : @"The receipt could not be authenticated.",
                        @(21004) : @"The shared secret you provided does not match the shared secret on file for your accunt.",
                        @(21005) : @"The receipt server is not currently available.",
                        @(21006) : @"This receipt is valid but the subscription has expired.",
                        @(21007) : @"This receipt is from the test environment.",
                        @(21008) : @"This receipt is from the production environment."};
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        self.products = [NSMutableDictionary dictionary];
        
        [self startValidatingReceipts:nil];
    }
    return self;
}

#pragma mark - Public
- (void)restore
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)registerProducts:(NSArray *)products
{
    NSMutableSet * productIdentifiers = [NSMutableSet set];
    for( MProduct * p in products )
    {
        [productIdentifiers addObject:p.productId];
        [self.products setObject:p forKey:p.productId];
    }
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    // Send the request to the App Store
    [request start];
}

- (void)buyProduct:(MProduct *)p
{
    if( p.product == nil )
    {
        p.isNeedToBuy = YES;
        
        [self registerProducts:@[p]];
    }
    else
    {
        [self buy:p.product];
    }
}

- (void)buy:(SKProduct *)product
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate

// Used to get the App Store's response to your request and notifies your observer
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSMutableArray * tempProducts = [NSMutableArray array];
    
    for( SKProduct * product in response.products )
    {
        MProduct * p = [self.products objectForKey:product.productIdentifier];
        
        if( p != nil )
        {
            p.product = product;

            [tempProducts addObject:p];
            
            if( p.isNeedToBuy )
                [self buy:product];
        }
    }
    
    if( [tempProducts count] > 0 )
    {
        if( _delegate!=nil && [_delegate respondsToSelector:@selector(storeManager:didReceiveInfoFor:)] )
            [_delegate storeManager:self didReceiveInfoFor:tempProducts];
    }
}

#pragma mark SKRequestDelegate method

// Called when the product request failed.
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    // Prints the cause of the product request failure
    NSLog(@"Product Request Status: %@",[error localizedDescription]);
}

#pragma mark - SKPaymentTransactionObserver methods

// Called when there are trasactions in the payment queue
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState )
        {
            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStateDeferred:
                // Do not block your UI. Allow the user to continue using your app.
                NSLog(@"Allow the user to continue using your app.");
                break;
                // The purchase was successful
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"Deliver content for %@",transaction.payment.productIdentifier);
                // Check whether the purchased product has content hosted with Apple.
                [self completeTransaction:transaction];
            }
                break;
                // There are restored products
            case SKPaymentTransactionStateRestored:
            {
                NSLog(@"Restore content for %@",transaction.payment.productIdentifier);
                [self completeTransaction:transaction];
            }
                break;
                // The transaction failed
            case SKPaymentTransactionStateFailed:
            {
                // Remove the transaction from the queue for purchased and restored statuses
                [self failedTransaction:transaction];
            }
                break;
            default:
                break;
        }
    }
}

// Logs all transactions that have been removed from the payment queue
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        NSLog(@"%@ was removed from the payment queue.", transaction.payment.productIdentifier);
    }
}

// Called when an error occur while restoring purchases. Notify the user about the error.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if( _delegate!=nil && [_delegate respondsToSelector:@selector(storeManagerRestored:withSuccess:)] )
        [_delegate storeManagerRestored:self withSuccess:NO];
}

// Called when all restorable transactions have been processed by the payment queue
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if( _delegate!=nil && [_delegate respondsToSelector:@selector(storeManagerRestored:withSuccess:)] )
        [_delegate storeManagerRestored:self withSuccess:YES];
}

#pragma mark - Complete transaction
// Notify the user about the purchase process. Start the download process if status is
-(void)completeTransaction:(SKPaymentTransaction *)transaction
{
    //Do not send any notifications when the user cancels the purchase
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        MProduct * product = [self.products objectForKey:transaction.payment.productIdentifier];
        if( product != nil )
        {
            product.isPuchased = YES;
            product.expireDate = transaction.transactionDate;
            
            if( product.isNeedValidatingReceipt )
            {
                product.expireDate = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]+24*2600*7];

                [self startValidatingReceipts:transaction.payment.requestData];
            }
            
            if( _delegate!=nil && [_delegate respondsToSelector:@selector(storeManager:didPurchaseProduct:withSuccess:)] )
                [_delegate storeManager:self didPurchaseProduct:product withSuccess:YES];
        }
    }
    
    // Remove the transaction from the queue for purchased and restored statuses
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    MProduct * product = [self.products objectForKey:transaction.payment.productIdentifier];
    if( product != nil )
    {
        if( _delegate!=nil && [_delegate respondsToSelector:@selector(storeManager:didPurchaseProduct:withSuccess:)] )
            [_delegate storeManager:self didPurchaseProduct:product withSuccess:NO];
    }
        
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - Validate Receipt
- (void)startValidatingReceipts:(NSData *)receiptData
{
    [self startValidatingAppStoreReceipt:receiptData WithCompletionHandler:^(NSArray *receipts, NSError *error)
    {
        if( error )
        {
            NSLog(@"Receipt validation failed with error: %@", error);
            if( _delegate!=nil && [_delegate respondsToSelector:@selector(storeManagerFinishedValidatingReceipt:withSuccess:)] )
                [_delegate storeManagerFinishedValidatingReceipt:self withSuccess:NO];
        }
        else
        {
            [receipts enumerateObjectsUsingBlock:^(NSDictionary *receiptDictionary, NSUInteger idx, BOOL *stop)
            {
                NSString *productIdentifier = receiptDictionary[@"product_id"];
                NSNumber *expiresDateMs = receiptDictionary[@"expires_date_ms"];

                MProduct * product = [self.products objectForKey:productIdentifier];
                if( product != nil )
                {
                    product.isPuchased = YES;
                    // renewable subscription
                    if( expiresDateMs )
                    {
                        if( product.expireDate == nil )
                            product.expireDate = [NSDate dateWithTimeIntervalSince1970:[expiresDateMs doubleValue]/1000.0f];
                        else
                        {
                            if( [expiresDateMs doubleValue]/1000.0f > [product.expireDate timeIntervalSince1970] )
                                product.expireDate = [NSDate dateWithTimeIntervalSince1970:[expiresDateMs doubleValue]/1000.0f];
                        }
                    }
                    
                    [product save];
                }
            }];
            
            if( _delegate!=nil && [_delegate respondsToSelector:@selector(storeManagerFinishedValidatingReceipt:withSuccess:)] )
                [_delegate storeManagerFinishedValidatingReceipt:self withSuccess:YES];
        }
    }];
}

- (void)startValidatingAppStoreReceipt:(NSData *)receiptData WithCompletionHandler:(void (^)(NSArray *receipts, NSError *error)) completionHandler
{
    if( receiptData == nil )
    {
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        NSError *receiptError;
        BOOL isPresent = [receiptURL checkResourceIsReachableAndReturnError:&receiptError];
        if( !isPresent )
        {
            // No receipt - In App Purchase was never initiated
            completionHandler(nil, nil);
            return;
        }
        
        receiptData = [NSData dataWithContentsOfURL:receiptURL];
    }

    if( !receiptData )
    {
        // Validation fails
        NSLog(@"Receipt exists but there is no data available. Try refreshing the reciept payload and then checking again.");
        completionHandler(nil, nil);
        return;
    }
    
    NSError *error;
    NSMutableDictionary *requestContents = [NSMutableDictionary dictionaryWithObject:
                                            [receiptData base64EncodedStringWithOptions:0] forKey:@"receipt-data"];
    requestContents[@"password"] = kSharedSecret;
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    
#ifdef DEBUG
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSandboxServer]];
#else
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kLiveServer]];
#endif
    
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:storeRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if( !error )
        {
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSInteger status = [jsonResponse[@"status"] integerValue];
            
            if( jsonResponse[@"receipt"] != [NSNull null] )
            {
                NSString *originalAppVersion = jsonResponse[@"receipt"][@"original_application_version"];
                if( nil != originalAppVersion )
                {
                    //[self.purchaseRecord setObject:originalAppVersion forKey:kOriginalAppVersionKey];
                    //[self savePurchaseRecord];
                }
                else
                {
                    completionHandler(nil, nil);
                }
            }
            else
            {
                completionHandler(nil, nil);
            }
            
            if( status != 0 )
            {
                NSError *error = [NSError errorWithDomain:@"com.mugunthkumar.mkstorekit" code:status
                                                 userInfo:@{NSLocalizedDescriptionKey : errorDictionary[@(status)]}];
                completionHandler(nil, error);
            }
            else
            {
                NSMutableArray *receipts = [jsonResponse[@"latest_receipt_info"] mutableCopy];
                if( jsonResponse[@"receipt"] != [NSNull null] )
                {
                    NSArray *inAppReceipts = jsonResponse[@"receipt"][@"in_app"];
                    [receipts addObjectsFromArray:inAppReceipts];
                    completionHandler(receipts, nil);
                }
                else
                {
                    completionHandler(nil, nil);
                }
            }
        }
        else
        {
            completionHandler(nil, error);
        }
    }] resume];
}

@end

@implementation MProduct
- (id)initWithProductId:(NSString *)Id
{
    self = [super init];
    if( self != nil )
    {
        self.productId = Id;
        
        self.isPuchased = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_IsPurchased", Id]];
        self.expireDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_ExpireDate", Id]];
        
        self.product = nil;
        self.isNeedToBuy = NO;
        self.isNeedValidatingReceipt = NO;
    }

    return self;
}

- (void)save
{
    [[NSUserDefaults standardUserDefaults] setBool:_isPuchased forKey:[NSString stringWithFormat:@"%@_IsPurchased", _productId]];
    if( _expireDate != nil )
        [[NSUserDefaults standardUserDefaults] setObject:_expireDate forKey:[NSString stringWithFormat:@"%@_ExpireDate", _productId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isUsable
{
    if( !_isNeedValidatingReceipt )
        return _isPuchased;
    
    return (_isPuchased && [_expireDate compare:[NSDate date]]==NSOrderedDescending);
}

- (NSString *)price
{
    NSString * p = nil;
    if( self.product != nil )
    {
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:self.product.priceLocale];
        p = [formatter stringFromNumber:self.product.price];
    }
    
    return p;
}

- (BOOL)isReceivedInfo
{
    return self.product!=nil;
}

@end