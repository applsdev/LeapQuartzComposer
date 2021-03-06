//
//  LeapQuartzComposerPlugIn.m
//  LeapQuartzComposer
//
//  Created by chris on 05/01/2013.
//  Copyright (c) 2013 Chris Birch. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>

#import "LeapQuartzComposerPlugIn.h"
#import "LeapQCHelper.h"


#define	kQCPlugIn_Name				@"Leap Device Interface"
#define	kQCPlugIn_Description		@"Version: 0.11\nAllows QC compositions to access data returned by Leap Motion devices"
#define kQCPlugIn_AuthorDescription @"© 2013 by Chris Birch, all rights reserved."

@interface LeapQuartzComposerPlugIn ()
{
    LeapController* leapController;
    LeapQCHelper *helper;
}

@end

@implementation LeapQuartzComposerPlugIn


//Port Synthesizes

@dynamic inputRetrieveHands;
@dynamic inputRetrieveFingers;
@dynamic inputRetrieveTools;
@dynamic inputRetrievePointables;
@dynamic inputIncludeFingersInHand;
@dynamic inputIncludeToolsInHand;
@dynamic inputIncludePointablesInHand;
@dynamic inputUseDictionariesToRepresentVectors;
@dynamic inputVectorsIncludeYawPitchRoll;
@dynamic outputHands;
@dynamic outputFingers;
@dynamic outputTools;
@dynamic outputPointables;
@dynamic outputFrame;
@dynamic outputScreens;



+ (NSDictionary *)attributes
{
	// Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
    return @{
                QCPlugInAttributeNameKey:kQCPlugIn_Name,
                QCPlugInAttributeDescriptionKey:kQCPlugIn_Description,
                QCPlugInAttributeCopyrightKey: kQCPlugIn_AuthorDescription
    
            };
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	// Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
    
    //Port Attributes
    
    //Yes if hands array is exposed to QC
    if([key isEqualToString:INPUT_RETRIEVEHANDS])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Retrieve Hands", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Yes if fingers array is exposed to QC
    else if([key isEqualToString:INPUT_RETRIEVEFINGERS])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Retrieve Fingers", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Yes if tools array is exposed to QC
    else if([key isEqualToString:INPUT_RETRIEVETOOLS])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Retrieve Tools", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Yes if pointables array is exposed to QC
    else if([key isEqualToString:INPUT_RETRIEVEPOINTABLES])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Retrieve Pointables", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Yes if fingers array is exposed in hand structure
    else if([key isEqualToString:INPUT_INCLUDEFINGERSINHAND])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Include Fingers In Hand", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Yes if tools array is exposed in hand structure
    else if([key isEqualToString:INPUT_INCLUDETOOLSINHAND])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Include Tools In Hand", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Yes if pointables array is exposed in hand structure
    else if([key isEqualToString:INPUT_INCLUDEPOINTABLESINHAND])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Include Pointables In Hand", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Dictates the type of QC compativle construct used to represent vectors
    else if([key isEqualToString:INPUT_USEDICTIONARIESTOREPRESENTVECTORS])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Use dictionaries to represent vectors", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Dictates whether or not vectors include yaw pitch and roll
    else if([key isEqualToString:INPUT_VECTORSINCLUDEYAWPITCHROLL])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Vectors include Yaw Pitch Roll", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //Array of Hand structures
    else if([key isEqualToString:OUTPUT_HANDS])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Hands", QCPortAttributeNameKey,
                nil];
    //Array of Finger structures
    else if([key isEqualToString:OUTPUT_FINGERS])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Fingers", QCPortAttributeNameKey,
                nil];
    //Array of tools
    else if([key isEqualToString:OUTPUT_TOOLS])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Tools", QCPortAttributeNameKey,
                nil];
    //Array of pointables
    else if([key isEqualToString:OUTPUT_POINTABLES])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Pointables", QCPortAttributeNameKey,
                nil];
    //Information about the frame
    else if([key isEqualToString:OUTPUT_FRAME])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Frame", QCPortAttributeNameKey,
                nil];
    //Exposes the screens as a QC array
    else if([key isEqualToString:OUTPUT_SCREENS])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Screens", QCPortAttributeNameKey,
                nil];
    
    return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	return kQCPlugInTimeModeIdle;
}

- (id)init
{
	self = [super init];
	if (self)
    {

        helper = [[LeapQCHelper alloc] init];
        
        //set up helper
        helper.outputVectorsAsDictionaries = YES;
        helper.outputYawPitchRoll = YES;
        
	}
	
	return self;
}







#pragma mark - SampleDelegate Callbacks

- (void)onInit:(LeapController*)aController
{
    NSLog(@"Initialized");
}

- (void)onConnect:(LeapController*)aController
{
    NSLog(@"Connected");
}

- (void)onDisconnect:(LeapController*)aController
{
    NSLog(@"Disconnected");
}

- (void)onFrame:(LeapController*)aController
{
      
    
}



@end

@implementation LeapQuartzComposerPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	
    //Create the leap controller
    leapController = [[LeapController alloc] initWithDelegate:self];
    
    
	return leapController != nil;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
    
    //Generated code:
    
    
    //Port Value Changed code
    
    //Skipping Value changed section for property: RetrieveHands as no values have been supplied for valueChangedTarget or valueChangedBody
    //Skipping Value changed section for property: RetrieveFingers as no values have been supplied for valueChangedTarget or valueChangedBody
    //Skipping Value changed section for property: RetrieveTools as no values have been supplied for valueChangedTarget or valueChangedBody
    //Skipping Value changed section for property: RetrievePointables as no values have been supplied for valueChangedTarget or valueChangedBody
    //Yes if fingers array is exposed in hand structure
    if ([self didValueForInputKeyChange:INPUT_INCLUDEFINGERSINHAND])
    {
        helper.includeFingersInHand = self.inputIncludeFingersInHand;
    }
    //Yes if tools array is exposed in hand structure
    if ([self didValueForInputKeyChange:INPUT_INCLUDETOOLSINHAND])
    {
        helper.includeToolsInHand = self.inputIncludeToolsInHand;
    }
    //Yes if pointables array is exposed in hand structure
    if ([self didValueForInputKeyChange:INPUT_INCLUDEPOINTABLESINHAND])
    {
        helper.includePointablesInHand = self.inputIncludePointablesInHand;
    }
    //Dictates the type of QC compativle construct used to represent vectors
    if ([self didValueForInputKeyChange:INPUT_USEDICTIONARIESTOREPRESENTVECTORS])
    {
        helper.outputVectorsAsDictionaries = self.inputUseDictionariesToRepresentVectors;
    }
    //Dictates whether or not vectors include yaw pitch and roll
    if ([self didValueForInputKeyChange:INPUT_VECTORSINCLUDEYAWPITCHROLL])
    {
        helper.outputYawPitchRoll = self.inputVectorsIncludeYawPitchRoll;
    }

    

    
    //Plugin code:
    

    // Get the most recent frame and report some basic information
    LeapFrame* frame = [leapController frame:0];
    

    //include the frame
    self.outputFrame = [helper leapFrameToDictionary:frame];;
    //include the screens
    self.outputScreens = [helper leapScreensToQCCompatibleArray:leapController.calibratedScreens];
    
    if (self.inputRetrieveHands)
    {
        self.outputHands = [helper leapHandsToQCCompatibleArray:frame.hands];
    }
    
    if (self.inputRetrieveFingers)
    {
        self.outputFingers = [helper leapPointablesToQCCompatibleArray:frame.fingers];
    }
    
    if(self.inputRetrievePointables)
    {
        self.outputPointables = [helper leapPointablesToQCCompatibleArray:frame.pointables];
    }
    if(self.inputRetrieveTools)
    {
        self.outputTools = [helper leapPointablesToQCCompatibleArray:frame.tools];
    }
    
    
    //NSLog(@"%@",qcCompatibleFrameDictionary);

	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
    
}

@end
