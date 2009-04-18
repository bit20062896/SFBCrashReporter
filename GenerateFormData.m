/*
 *  Copyright (C) 2009 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import "GenerateFormData.h"

NSData *
GenerateFormData(NSDictionary *formValues, NSString *boundary)
{
	NSCParameterAssert(nil != formValues);
	NSCParameterAssert(nil != boundary);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	// Iterate over the form elements' keys and append their values
	NSArray *keys = [formValues allKeys];
	for(NSString *key in keys) {
		id value = [formValues valueForKey:key];
		
		[result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		// String value
		if([value isKindOfClass:[NSString class]]) {
			NSString *string = (NSString *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[@"Content-Type: text/plain; charset=utf-8\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		// Number value
		else if([value isKindOfClass:[NSNumber class]]) {
			NSNumber *number = (NSNumber *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[@"Content-Type: text/plain; charset=utf-8\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[[[number stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		// URL value (only file URLs are supported)
		else if([value isKindOfClass:[NSURL class]] && [(NSURL *)value isFileURL]) {
			NSURL *url = (NSURL *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, [[url path] lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[@"Content-Type: application/octet-stream\r\n\r" dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[NSData dataWithContentsOfURL:url]];
		}
		// Illegal class
		else
			NSLog(@"SFBCrashReporterError: formValues contained illegal object %@ of class %@", value, [value class]);
		
		[result appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[result appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [result autorelease];
}
