#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class MGSMapAnnotation;
@class MGSMapCoordinate;
@class MGSMarker;
@class MGSMapView;
@class MGSLayer;

@protocol MGSAnnotation;

@protocol MGSLayerDelegate <NSObject>
@optional
- (void)mapLayer:(MGSLayer*)layer willAddAnnotations:(NSArray*)annotations;
- (void)mapLayer:(MGSLayer*)layer didAddAnnotations:(NSArray*)annotations;

- (void)mapLayer:(MGSLayer*)layer willRemoveAnnotations:(NSArray*)annotations;
- (void)mapLayer:(MGSLayer*)layer didRemoveAnnotations:(NSArray*)annotations;
@end

@interface MGSLayer : NSObject
@property (nonatomic,weak) id<MGSLayerDelegate> delegate;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSArray *annotations;

+ (MKCoordinateRegion)regionForAnnotations:(NSSet*)annotations;

- (void)addAnnotation:(id<MGSAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)objects;
- (void)deleteAnnotation:(id<MGSAnnotation>)annotation;
- (void)deleteAnnotations:(NSArray*)annotation;
- (void)deleteAllAnnotations;

- (MKCoordinateRegion)regionForAnnotations;

- (id)initWithName:(NSString*)name;
@end

@interface MGSLayer (Subclassing)
- (void)willAddAnnotations:(NSArray*)annotations;
- (void)didAddAnnotations:(NSArray*)annotations;
- (void)willRemoveAnnotations:(NSArray*)annotations;
- (void)didRemoveAnnotations:(NSArray*)annotations;
@end