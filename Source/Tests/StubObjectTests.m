//  OCMockito by Jon Reid, http://qualitycoding.org/about/
//  Copyright 2015 Jonathan M. Reid. See LICENSE.txt

#define MOCKITO_SHORTHAND
#import "OCMockito.h"

#import "NSInvocation+OCMockito.h"

// Test support
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

typedef void (^StubObjectBlockArgument)(void);

typedef struct {
    int anInt;
    char aChar;
    double *arrayOfDoubles;
} MKTStruct;

static inline double *createArrayOf10Doubles(void)
{
    return malloc(10 * sizeof(double));
}


@interface PropertyObject : NSObject
@property (nonatomic, assign) int intValue;
@end

@implementation PropertyObject
@end


@interface ReturningObject : NSObject
@end

@implementation ReturningObject

- (void)methodReturningNothing {}

- (id)methodReturningObject { return self; }
- (Class)methodReturningClass { return [self class]; }
- (Class)methodReturningClassWithClassArg:(Class)arg { return [self class]; }
- (id)methodReturningObjectWithArg:(id)arg { return self; }
- (id)methodReturningObjectWithIntArg:(int)arg { return self; }
- (id)methodReturningObjectWithBlockArg:(StubObjectBlockArgument)arg { return self; }
- (id)methodReturningObjectWithStruct:(MKTStruct)arg { return nil; };

- (BOOL)methodReturningBool { return NO; }
- (char)methodReturningChar { return 0; }
- (int)methodReturningInt { return 0; }
- (short)methodReturningShort { return 0; }
- (long)methodReturningLong { return 0; }
- (long long)methodReturningLongLong { return 0; }
- (NSInteger)methodReturningInteger { return 0; }
- (unsigned char)methodReturningUnsignedChar { return 0; }
- (unsigned int)methodReturningUnsignedInt { return 0; }
- (unsigned short)methodReturningUnsignedShort { return 0; }
- (unsigned long)methodReturningUnsignedLong { return 0; }
- (unsigned long long)methodReturningUnsignedLongLong { return 0; }
- (NSUInteger)methodReturningUnsignedInteger { return 0; }
- (float)methodReturningFloat { return 0; }
- (double)methodReturningDouble { return 0; }
- (MKTStruct)methodReturningStruct { MKTStruct returnedStruct; return returnedStruct; }

@end


@interface StubObjectTests : SenTestCase
@end

@implementation StubObjectTests
{
    ReturningObject *mockObject;
}

- (void)setUp
{
    [super setUp];
    mockObject = mock([ReturningObject class]);
}

- (void)testStubbedMethodReturningObject_ShouldReturnGivenObject
{
    [given([self->mockObject methodReturningObject]) willReturn:@"STUBBED"];

    assertThat([mockObject methodReturningObject], is(@"STUBBED"));
}

- (void)testUnstubbedMethodReturningObject_ShouldReturnNil
{
    assertThat([mockObject methodReturningObject], is(nilValue()));
}

- (void)testStubbedMethodReturningClass_ShouldReturnGivenClass
{
    [given([self->mockObject methodReturningClass]) willReturn:[NSString class]];

    assertThat([mockObject methodReturningClass], is([NSString class]));
}

- (void)testUnstubbedMethodReturningClass_ShouldReturnNil
{
    assertThat([mockObject methodReturningClass], is(nilValue()));
}

- (void)testStubbedMethodReturningObject_WithDifferentArgs_ShouldReturnValueForMatchingArgument
{
    [given([self->mockObject methodReturningObjectWithArg:@"foo"]) willReturn:@"FOO"];
    [given([self->mockObject methodReturningObjectWithArg:@"bar"]) willReturn:@"BAR"];

    assertThat([mockObject methodReturningObjectWithArg:@"foo"], is(@"FOO"));
}

- (void)testStubbedMethodReturningClass_WithDifferentClassArgs_ShouldReturnClassForMatchingArgument
{
    [given([self->mockObject methodReturningClassWithClassArg:[NSString class]]) willReturn:[NSString class]];
    [given([self->mockObject methodReturningClassWithClassArg:[NSData class]]) willReturn:[NSData class]];

    assertThat([mockObject methodReturningClassWithClassArg:[NSString class]], is([NSString class]));
}

- (void)testStub_ShouldAcceptArgumentMatchers
{
    [given([self->mockObject methodReturningObjectWithArg:equalTo(@"foo")]) willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithArg:@"foo"], is(@"FOO"));
}

- (void)testStubbedMethodWithPrimitiveNumericArg_ShouldReturnValueForMatchingArgument
{
    [given([self->mockObject methodReturningObjectWithIntArg:1]) willReturn:@"FOO"];
    [given([self->mockObject methodReturningObjectWithIntArg:2]) willReturn:@"BAR"];

    assertThat([mockObject methodReturningObjectWithIntArg:1], is(@"FOO"));
}

- (void)testStubbedMethodWithBlockArg_WithSameBlockArg_ShouldReturnGivenValue
{
    StubObjectBlockArgument block = ^{ };
    [given([self->mockObject methodReturningObjectWithBlockArg:block]) willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithBlockArg:block], is(@"FOO"));
}

- (void)testStubbedMethodWithBlockArg_WithDifferentBlockArg_ShouldNotReturnGivenValue
{
    StubObjectBlockArgument emptyBlock = ^{ };
    StubObjectBlockArgument anotherEmptyBlock = ^{ };
    [given([self->mockObject methodReturningObjectWithBlockArg:emptyBlock]) willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithBlockArg:anotherEmptyBlock], isNot(@"FOO"));
}

- (void)testStubbedMethodWithBlockArg_WithInlineBlockArg_ShouldReturnNil
{
    [given([self->mockObject methodReturningObjectWithBlockArg:^{ }]) willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithBlockArg:^{ }], is(nilValue()));
}

- (void)testStubbedMethodWithBlockArg_WithInlineBlockArgCapturingScopeVariable_ShouldReturnNilWithoutDying
{
    NSNumber *someVariable = @0;
    [given([self->mockObject methodReturningObjectWithBlockArg:^{ [someVariable description]; }])
           willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithBlockArg:^{ [someVariable description]; }],
               is(nilValue()));
}

- (void)testStubbedMethodWithStructArg_WithSameStruct_ShouldReturnGivenValue
{
    double *a = createArrayOf10Doubles();
    MKTStruct struct1 = { 1, 'a', a };
    [given([self->mockObject methodReturningObjectWithStruct:struct1]) willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithStruct:struct1], is(@"FOO"));

    free(a);
}

- (void)testStubbedMethodWithStructArg_WithEqualStruct_ShouldReturnGivenValue
{
    double *a = createArrayOf10Doubles();
    MKTStruct struct1 = { 1, 'a', a };
    MKTStruct struct2 = { 1, 'a', a };
    [given([self->mockObject methodReturningObjectWithStruct:struct1]) willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithStruct:struct2], is(@"FOO"));

    free(a);
}

- (void)testStubbedMethodWithStructArg_WithDifferentStruct_ShouldReturnNil
{
    double *a = createArrayOf10Doubles();
    double *b = createArrayOf10Doubles();
    MKTStruct struct1 = { 1, 'a', a };
    MKTStruct struct2 = { 1, 'a', b };
    [given([self->mockObject methodReturningObjectWithStruct:struct1]) willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithStruct:struct2], is(nilValue()));

    free(a);
    free(b);
}

- (void)testStub_ShouldAcceptMatcherForNumericArgument
{
    [[given([self->mockObject methodReturningObjectWithIntArg:0])
            withMatcher:greaterThan(@1) forArgument:0]
            willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithIntArg:2], is(@"FOO"));
}

- (void)testShouldSupportShortcutForSpecifyingMatcherForFirstArgument
{
    [[given([self->mockObject methodReturningObjectWithIntArg:0])
            withMatcher:greaterThan(@1)]
            willReturn:@"FOO"];

    assertThat([mockObject methodReturningObjectWithIntArg:2], is(@"FOO"));
}

- (void)testStubbedMethodReturningBool_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningBool]) willReturnBool:YES];

    STAssertTrue([mockObject methodReturningBool], nil);
}

- (void)testStubbedMethodReturningChar_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningChar]) willReturnChar:'a'];

    assertThat(@([mockObject methodReturningChar]), is(@'a'));
}

- (void)testStubbedMethodReturningInt_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningInt]) willReturnInt:42];

    assertThat(@([mockObject methodReturningInt]), is(@42));
}

- (void)testStubbedMethodReturningShort_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningShort]) willReturnShort:42];

    assertThat(@([mockObject methodReturningShort]), is(@42));
}

- (void)testStubbedMethodReturningLong_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningLong]) willReturnLong:42];

    assertThat(@([mockObject methodReturningLong]), is(@42));
}

- (void)testStubbedMethodReturningLongLong_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningLongLong]) willReturnLongLong:42];

    assertThat(@([mockObject methodReturningLongLong]), is(@42));
}

- (void)testStubbedMethodReturningInteger_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningInteger]) willReturnInteger:42];

    assertThat(@([mockObject methodReturningInteger]), is(@42));
}

- (void)testStubbedMethodReturningUnsignedChar_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningUnsignedChar]) willReturnUnsignedChar:'a'];

    assertThat(@([mockObject methodReturningUnsignedChar]), is(@'a'));
}

- (void)testStubbedMethodReturningUnsignedInt_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningUnsignedInt]) willReturnUnsignedInt:42];

    assertThat(@([mockObject methodReturningUnsignedInt]), is(@42));
}

- (void)testStubbedMethodReturningUnsignedShort_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningUnsignedShort]) willReturnUnsignedShort:42];

    assertThat(@([mockObject methodReturningUnsignedShort]), is(@42));
}

- (void)testStubbedMethodReturningUnsignedLong_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningUnsignedLong]) willReturnUnsignedLong:42];

    assertThat(@([mockObject methodReturningUnsignedLong]), is(@42));
}

- (void)testStubbedMethodReturningUnsignedLongLong_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningUnsignedLongLong]) willReturnUnsignedLongLong:42];

    assertThat(@([mockObject methodReturningUnsignedLongLong]), is(@42));
}

- (void)testStubbedMethodReturningUnsignedInteger_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningUnsignedInteger]) willReturnUnsignedInteger:42];

    assertThat(@([mockObject methodReturningUnsignedInteger]), is(@42));
}

- (void)testStubbedMethodReturningFloat_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningFloat]) willReturnFloat:42.5f];

    assertThat(@([mockObject methodReturningFloat]), is(@42.5f));
}

- (void)testStubbedMethodReturningDouble_ShouldReturnGivenValue
{
    [given([self->mockObject methodReturningDouble]) willReturnDouble:42.0];

    assertThat(@([mockObject methodReturningDouble]), is(@42.0));
}

- (void)testStubbedMethodReturningStruct_ShouldReturnGivenValue
{
    MKTStruct someStruct = { 123, 'a', NULL };
    [given([self->mockObject methodReturningStruct]) willReturnStruct:&someStruct
                                                       objCType:@encode(MKTStruct)];

    MKTStruct otherStruct = [mockObject methodReturningStruct];

    assertThat(@(otherStruct.anInt), is(@123));
    assertThat(@(otherStruct.aChar), is(@'a'));
}

- (void)testStubbingProperty_ShouldStubValue
{
    PropertyObject *obj = mock([PropertyObject class]);

    stubProperty(obj, intValue, @42);

    assertThat(@([obj intValue]), is(@42));
}

- (void)testStubbingProperty_ShouldStubValueForKey_SoPredicatesWork
{
    PropertyObject *obj = mock([PropertyObject class]);
    stubProperty(obj, intValue, @42);

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"intValue == 42"];
    NSArray *array = [@[ obj ] filteredArrayUsingPredicate:predicate];

    assertThat(array, hasCountOf(1));
}

- (void)testStubbingProperty_ShouldStubValueForKeyPath_SoSortDescriptorsWork
{
    PropertyObject *obj1 = mock([PropertyObject class]);
    stubProperty(obj1, intValue, @1);
    PropertyObject *obj2 = mock([PropertyObject class]);
    stubProperty(obj2, intValue, @2);
    NSArray *unsortedArray = @[obj2, obj1];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"intValue"
                                                                     ascending:YES];
    NSArray *sortedArray = [unsortedArray sortedArrayUsingDescriptors:@[sortDescriptor]];

    assertThat(sortedArray, contains(sameInstance(obj1), sameInstance(obj2), nil));
}

- (void)testMultipleStubbedReturns_ShouldReturnEachThenRepeatLast
{
    [[[given([self->mockObject methodReturningObject]) willReturn:@"A"] willReturn:nil] willReturn:@"B"];

    assertThat([mockObject methodReturningObject], is(@"A"));
    assertThat([mockObject methodReturningObject], is(nilValue()));
    assertThat([mockObject methodReturningObject], is(@"B"));
    assertThat([mockObject methodReturningObject], is(@"B"));
}

- (void)testMockWithoutStubbedReturn_ShouldReturnNil
{
    given([self->mockObject methodReturningObject]);

    assertThat([mockObject methodReturningObject], is(nilValue()));
}

- (void)testStubbingThrow_ShouldThrow
{
    NSException *exception = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    [given([self->mockObject methodReturningObject]) willThrow:exception];

    assertThat(^{ [self->mockObject methodReturningObject]; },
               throwsException(sameInstance(exception)));
}

- (void)testStubbingWithBlock_ShouldReturnWhatBlockReturns
{
    [given([self->mockObject methodReturningObject]) willDo:^id (NSInvocation *invocation){
        return @"FOO";
    }];

    assertThat([mockObject methodReturningObject], is(@"FOO"));
}

- (void)testStubbingWithBlock_ShouldBeAbleToAccessInvocationArguments
{
    [given([self->mockObject methodReturningObjectWithArg:anything()]) willDo:^id (NSInvocation *invocation){
        NSArray *args = [invocation mkt_arguments];
        return @([args[0] intValue] * 2);
    }];

    assertThat([mockObject methodReturningObjectWithArg:@2], is(@4));
    assertThat([mockObject methodReturningObjectWithArg:@3], is(@6));
}

- (void)testStubbingWithBlock_shouldAllowMethodsWithoutReturnValue
{
    // this test verifies that given([self->mockObject methodReturningNothing]) is not a compiler error
    
    [given([self->mockObject methodReturningNothing]) willDo:^id (NSInvocation *invocation){
        return nil;
    }];
    
    [mockObject methodReturningNothing];
}

- (void)testStubbingWithBlock_shouldPerformSideEffects
{
    __block NSUInteger counter = 0;
    [given([self->mockObject methodReturningNothing]) willDo:^id (NSInvocation *invocation){
        ++counter;
        return nil;
    }];
    
    [mockObject methodReturningNothing];
    assertThat(@(counter), is(@1));
}

@end
