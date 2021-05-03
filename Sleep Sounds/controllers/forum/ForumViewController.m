//
//  ForumViewController.m
//  7 Minute Workout
//
//  Created by Ditriol Wei on 29/7/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "ForumViewController.h"

@interface ForumViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ForumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:41.0f/255.0f green:59.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationItem.title = @"Forum";
    UIBarButtonItem * settingBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clear"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onClose:)];
    settingBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = settingBarButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self onHome:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // Intercept calls to the 'localytics' protocol
    
//    NSLog(@"Sheme: %@",request.URL);
//    
//    if ([request.URL.scheme isEqualToString:@"localytics"])
//    {
//        NSString *event = [self valueFromQueryStringKey:@"event" url:request.URL];
//        if (event)
//        {
//            NSString *attributes = [self valueFromQueryStringKey:@"attributes" url:request.URL];
//            NSDictionary* attributesDict = nil;
//            if(attributes)
//            {
//                NSData *attributesData = [attributes dataUsingEncoding:NSUTF8StringEncoding];
//                attributesDict = [NSJSONSerialization JSONObjectWithData:attributesData
//                                                                 options:NSJSONReadingMutableLeaves error:nil];
//            }
//            
//            // Perform the native tagging call with the retrieved data
//            [Localytics tagEvent:event attributes:attributesDict];
//        }
//        
//        // From here, cancel the request. Don't let the webView try and load our custom URL
//        return NO;
//    }
    
    // Otherwise, load the request in the webView
    return YES;
}

// Helper function for extracting querystring key/value pairs
//- (NSString *)valueFromQueryStringKey:(NSString *)queryStringKey url:(NSURL *)url
//{
//    if (!queryStringKey.length || !url.query)
//        return nil;
//    
//    NSArray *urlComponents = [url.query componentsSeparatedByString:@"&"];
//    for (NSString *keyValuePair in urlComponents)
//    {
//        NSArray *keyValuePairComponents = [keyValuePair componentsSeparatedByString:@"="];
//        if ([[keyValuePairComponents objectAtIndex:0] isEqualToString:queryStringKey])
//        {
//            if(keyValuePairComponents.count == 2)
//                return [[keyValuePairComponents objectAtIndex:1]
//                        stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        }
//    }
//    
//    return nil;
//}

#pragma mark - Butten Event

- (void)onClose:(id)sender
{
    if( [self.navigationController.viewControllers count] == 1 )
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onHome:(id)sender
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]
                                       initWithURL:[NSURL URLWithString:[@"http://forums.zenlabsfitness.com/" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
    [urlRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [_webView loadRequest:urlRequest];
}



@end
