//
// Created by Alex on 10/10/13.
// Copyright (c) 2013 DS ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol DSDraggingSourceContainer;
@protocol DSDraggingDestinationContainer;


@interface DSDragAndDropController : NSObject
- (id)initWithSource:(UIView<DSDraggingSourceContainer> *)source
         destination:(UIView<DSDraggingDestinationContainer> *)destination
        draggingArea:(UIView *)draggingArea;

@end