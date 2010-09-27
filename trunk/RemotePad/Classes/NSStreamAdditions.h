//
//  NSStreamAdditions.h
//  RemotePad
//
//  Created by Rui Paulo on 27/09/2010.
//  Copyright 2008, 2009, 2010 tenjin.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStream (MyAdditions)

+ (void)getStreamsToHostNamed:(NSString *)hostName 
						 port:(NSInteger)port 
				  inputStream:(NSInputStream **)inputStreamPtr 
				 outputStream:(NSOutputStream **)outputStreamPtr;

@end
