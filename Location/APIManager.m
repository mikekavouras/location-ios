#import "APIManager.h"

@interface APIManager()

@property (nonatomic, retain) NSMutableData *responseData;

@end

@implementation APIManager

- (void)startConnectionWithURLRoot:(NSString *)urlRoot params:(NSDictionary *)params andBody:(NSData *)body
{
    NSString *urlString = urlRoot;
    
    if (params) {
        for (NSString *key in params) {
            NSString *value = [params objectForKey:key];
            NSString *param = [NSString stringWithFormat:@"%@=%@&", key, value];
            urlString = [urlString stringByAppendingString:param];
        }
    }
    
    urlString = [urlString substringWithRange:NSMakeRange(0, urlString.length - 1)];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:15.0];
    request.HTTPMethod = @"POST";
    if (body) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: body];
    }
    
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request
                                                                delegate:self];
    
    if (connection) {
        self.responseData = [[NSMutableData alloc] init];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh crap!"
                                                        message:@"We couldn't connect to the cloud :("
                                                       delegate:self
                                              cancelButtonTitle:@"Again?"
                                              otherButtonTitles:nil];
        
        [alert show];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    
    
    if ([json objectForKey:@"errors"]) {
        NSDictionary *errors = [NSDictionary dictionaryWithObject:@"wrong" forKey:@"error"];
        [self.delegate didFailWithErrors:errors];
    } else {
        [self.delegate didSucceedWithJSON:json];
    }

}

@end
