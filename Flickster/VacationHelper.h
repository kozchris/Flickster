//
//  VacationHelper.h
//  Flickster
//
//  Created by Christopher Snyder on 8/12/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *vacationDocument);

@interface VacationHelper : NSObject

+ (void)openVacation:(NSString *)vacationName
          usingBlock:(completion_block_t)completionBlock;

@end
