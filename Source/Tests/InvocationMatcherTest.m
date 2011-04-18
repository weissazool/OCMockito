//
//  OCMockito - InvocationMatcherTest.m
//  Copyright 2011 Jonathan M. Reid. See LICENSE.txt
//

    // Class under test
#import "MTInvocationMatcher.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#if TARGET_OS_MAC
    #import <OCHamcrest/OCHamcrest.h>
#else
    #import <OCHamcrestIOS/OCHamcrestIOS.h>
#endif


@interface DummyObject : NSObject
@end

@implementation DummyObject

- (void)methodWithNoArgs {}
- (void)differentMethodWithNoArgs {}

- (void)methodWithObjectArg:(id)arg {}
- (void)differentMethodWithObjectArg:(id)arg {}

- (void)methodWithBoolArg:(BOOL)arg {}
- (void)methodWithCharArg:(char)arg {}
- (void)methodWithIntArg:(int)arg {}

- (void)methodWithObjectArg:(id)arg1 intArg:(int)arg2 {}

+ (NSInvocation *)invocationWithSelector:(SEL)selector
{
    NSMethodSignature *methodSignature = [self instanceMethodSignatureForSelector:selector];
    return [NSInvocation invocationWithMethodSignature:methodSignature];
}

+ (NSInvocation *)invocationWithNoArgs
{
    return [self invocationWithSelector:@selector(methodWithNoArgs)];
}

+ (NSInvocation *)invocationWithObjectArg:(id)argument
{
    NSInvocation *invocation = [self invocationWithSelector:@selector(methodWithObjectArg:)];
    [invocation setArgument:&argument atIndex:2];
    return invocation;
}

+ (NSInvocation *)invocationWithBoolArg:(BOOL)argument
{
    NSInvocation *invocation = [self invocationWithSelector:@selector(methodWithBoolArg:)];
    [invocation setArgument:&argument atIndex:2];
    return invocation;
}

+ (NSInvocation *)invocationWithCharArg:(char)argument
{
    NSInvocation *invocation = [self invocationWithSelector:@selector(methodWithCharArg:)];
    [invocation setArgument:&argument atIndex:2];
    return invocation;
}

+ (NSInvocation *)invocationWithIntArg:(int)argument
{
    NSInvocation *invocation = [self invocationWithSelector:@selector(methodWithIntArg:)];
    [invocation setArgument:&argument atIndex:2];
    return invocation;
}

+ (NSInvocation *)invocationWithObjectArg:(id)argument1 intArg:(int)argument2
{
    NSInvocation *invocation = [self invocationWithSelector:@selector(methodWithObjectArg:intArg:)];
    [invocation setArgument:&argument1 atIndex:2];
    [invocation setArgument:&argument2 atIndex:3];
    return invocation;
}

@end


#pragma mark -

@interface InvocationMatcherTest : SenTestCase
{
    MTInvocationMatcher *invocationMatcher;
}
@end


@implementation InvocationMatcherTest

- (void)setUp
{
    [super setUp];
    invocationMatcher = [[MTInvocationMatcher alloc] init];
}


- (void)tearDown
{
    [invocationMatcher release];
    [super tearDown];
}


- (void)testShouldMatchNoArgumentInvocationsIfSelectorsMatch
{
    NSInvocation *expected = [DummyObject invocationWithNoArgs];
    NSInvocation *actual = [DummyObject invocationWithNoArgs];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


- (void)testShouldNotMatchNoArgumentInvocationsIfSelectorsDiffer
{
    NSInvocation *expected = [DummyObject invocationWithNoArgs];
    NSInvocation *actual = [DummyObject invocationWithNoArgs];
    [expected setSelector:@selector(methodWithNoArgs)];
    [actual setSelector:@selector(differentMethodWithNoArgs)];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertFalse([invocationMatcher matches:actual], nil);
}


- (void)testShouldMatchIfObjectArgumentEqualsExpectedArgument
{
    NSInvocation *expected = [DummyObject invocationWithObjectArg:@"something"];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"something"];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


- (void)testShouldNotMatchIfObjectArgumentDoesNotEqualExpectedArgument
{
    NSInvocation *expected = [DummyObject invocationWithObjectArg:@"something"];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"different"];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertFalse([invocationMatcher matches:actual], nil);
}


- (void)testShouldNotMatchIfArgumentsMatchButSelectorsDiffer
{
    NSInvocation *expected = [DummyObject invocationWithObjectArg:@"something"];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"something"];
    [expected setSelector:@selector(methodWithObjectArg:)];
    [actual setSelector:@selector(differentMethodWithObjectArg:)];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertFalse([invocationMatcher matches:actual], nil);
}


- (void)testShouldMatchIfObjectArgumentSatisfiesArgumentExpectation
{
    id <HCMatcher> argumentExpectation = equalTo(@"something");
    NSInvocation *expected = [DummyObject invocationWithObjectArg:argumentExpectation];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"something"];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


- (void)testShouldNotMatchIfObjectArgumentDoesNotSatisfyArgumentExpectation
{
    id <HCMatcher> argumentExpectation = equalTo(@"something");
    NSInvocation *expected = [DummyObject invocationWithObjectArg:argumentExpectation];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"different"];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertFalse([invocationMatcher matches:actual], nil);
}


- (void)testShouldMatchIfBoolArgumentEqualsExpectedArgument
{
    NSInvocation *expected = [DummyObject invocationWithBoolArg:YES];
    NSInvocation *actual = [DummyObject invocationWithBoolArg:YES];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


- (void)testShouldNotMatchIfBoolArgumentDoesNotEqualExpectedArgument
{
    NSInvocation *expected = [DummyObject invocationWithBoolArg:NO];
    NSInvocation *actual = [DummyObject invocationWithBoolArg:YES];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertFalse([invocationMatcher matches:actual], nil);
}


- (void)testShouldMatchIfCharArgumentEqualsExpectedArgument
{
    NSInvocation *expected = [DummyObject invocationWithCharArg:'a'];
    NSInvocation *actual = [DummyObject invocationWithCharArg:'a'];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


- (void)testShouldNotMatchIfCharArgumentDoesNotEqualExpectedArgument
{
    NSInvocation *expected = [DummyObject invocationWithCharArg:'a'];
    NSInvocation *actual = [DummyObject invocationWithCharArg:'z'];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertFalse([invocationMatcher matches:actual], nil);
}


- (void)testShouldMatchIfCharArgumentConvertedToNSNumberSatisfiesOverrideMatcher
{
    NSInvocation *expected = [DummyObject invocationWithCharArg:0];   // This arg will be ignored.
    NSInvocation *actual = [DummyObject invocationWithCharArg:'z'];
    
    [invocationMatcher setMatcher:greaterThan([NSNumber numberWithChar:'n']) forIndex:2];
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


- (void)testShouldMatchIfIntArgumentEqualsExpectedArgument
{
    NSInvocation *expected = [DummyObject invocationWithIntArg:42];
    NSInvocation *actual = [DummyObject invocationWithIntArg:42];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


- (void)testShouldNotMatchIfIntArgumentDoesNotEqualExpectedArgument
{
    NSInvocation *expected = [DummyObject invocationWithIntArg:42];
    NSInvocation *actual = [DummyObject invocationWithIntArg:99];
    
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertFalse([invocationMatcher matches:actual], nil);
}


- (void)testShouldMatchIfIntArgumentConvertedToNSNumberSatisfiesOverrideMatcher
{
    NSInvocation *expected = [DummyObject invocationWithCharArg:0];   // This arg will be ignored.
    NSInvocation *actual = [DummyObject invocationWithCharArg:51];
    
    [invocationMatcher setMatcher:greaterThan([NSNumber numberWithInt:50]) forIndex:2];
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


- (void)testShouldMatchOverrideMatcherSpecifiedForSecondPrimitiveArgument
{
    NSInvocation *expected = [DummyObject invocationWithObjectArg:@"something" intArg:0];
    NSInvocation *actual = [DummyObject invocationWithObjectArg:@"something" intArg:51];
    
    [invocationMatcher setMatcher:greaterThan([NSNumber numberWithInt:50]) forIndex:3];
    [invocationMatcher setExpectedInvocation:expected];
    
    STAssertTrue([invocationMatcher matches:actual], nil);
}


@end
