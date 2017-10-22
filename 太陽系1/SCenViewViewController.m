//
//  SCenViewViewController.m
//  太陽系1
//
//  Created by XerangaWang on 2017/9/6.
//  Copyright © 2017年 XerangaWang. All rights reserved.
//

#import "SCenViewViewController.h"
//1. 導入頭文件
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface SCenViewViewController ()<ARSCNViewDelegate>

// AR 前置作業
@property(nonatomic, strong) ARSCNView * arSCNView;
@property(nonatomic, strong) ARSession * arSession;
@property(nonatomic, strong) ARConfiguration * arSessionConfiguation;

//地球 太陽 月亮
@property(nonatomic, strong)SCNNode * sunNode;
@property(nonatomic, strong)SCNNode * moonNode;
@property(nonatomic, strong)SCNNode * earthNode;
//地月結點: set earth and moon
@property(nonatomic, strong)SCNNode * earthGroupNode;
@property(nonatomic, strong)SCNNode * sunHaloNode;

@end

@implementation SCenViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化 AR 環境
    [self.view addSubview:self.arSCNView];
    self.arSCNView.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated{
    //    創建追蹤
    ARWorldTrackingConfiguration * configuation = [[ARWorldTrackingConfiguration alloc] init];
//    自適應燈光（室內到室外的話 畫面會比較柔和）
    _arSessionConfiguation = configuation;
    _arSessionConfiguation.lightEstimationEnabled = YES;
    [self.arSession runWithConfiguration:_arSessionConfiguation];
}

- (void)initNode {
    //    創建節點
    _sunNode = [SCNNode new];
    _earthNode = [SCNNode new];
    _moonNode = [SCNNode new];
    _earthGroupNode = [SCNNode new];
    
//    確定節點幾何
    _sunNode.geometry = [SCNSphere sphereWithRadius:3];
    _earthNode.geometry = [SCNSphere sphereWithRadius:1.0];
    _moonNode.geometry = [SCNSphere sphereWithRadius:0.5];
    //    渲染上圖
    //    multiply： 鑲嵌：把整張圖片拉伸，之後會變淡！
    _sunNode.geometry.firstMaterial.multiply.contents = @"art.scnassets/earth/sun.jpg";
//    地球上圖
    _earthNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/earth-diffuse-mini.jpg";
//    地球夜光圖
    _earthNode.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive-mini.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-specular-mini.jpg";
    
//    月球圖
    _moonNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/moon.jpg";
    
    //    diffuse: 擴散，平均擴散到整個物件的表面，並且光華透亮
    _sunNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun.jpg";
    
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5; //強度
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
//    wrapS 從左到右
//    wrapT 從上到下 （回頭提醒我把這邊住掉很嚇人）
    _sunNode.geometry.firstMaterial.multiply.wrapS =
    _sunNode.geometry.firstMaterial.diffuse.wrapS =
    _sunNode.geometry.firstMaterial.multiply.wrapT =
    _sunNode.geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    
//    太陽照到地球上的光層，還有反光度，地球的反光度
    _earthNode.geometry.firstMaterial.shininess = 0.1; // 光澤
    _earthNode.geometry.firstMaterial.specular.intensity = 0.5; // 反射多少光出去
    _moonNode.geometry.firstMaterial.specular.contents = [UIColor grayColor]; // ???
    
//    設置太陽的位置
    [_sunNode setPosition:SCNVector3Make(0, 5, -20)];
//    set earth posittion
    _earthNode.position = SCNVector3Make(3, 0, 0);
    _moonNode.position = SCNVector3Make(3, 0, 0); // 忘了設置月球的位置！愚蠢的Ｖｅｒｇｉｌ！
    [_earthGroupNode addChildNode:_earthNode]; // set earth in earthGround
//    set earthGround posittion
    _earthGroupNode.position = SCNVector3Make(10, 0, 0);
    
    
    
    [self.arSCNView.scene.rootNode addChildNode:_sunNode];
    
    [self addAnimationToSun];
    [self roationNode];
    [self addLight];
}
// Revolution 公轉
- (void) roationNode {
    [_earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];   //地球自转
//    set moon around earth (see the moon)
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:_moonNode];
    
//    moon Rotate first (set animation of moon rotate)
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 1.5;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [_moonNode addAnimation:animation forKey:@"moon rotation"];

    
//    the Animation of moon around earth scened (moon around earth)
    CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRotationAnimation.duration = 5.0;
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moonRotationAnimation.repeatCount = FLT_MAX;
    [moonRotationNode addAnimation:moonRotationAnimation forKey:@"moon rotation around earth"];

//    [moonRotationNode addChildNode:_moonNode];
    
    
    [_earthGroupNode addChildNode:moonRotationNode];
    
//    地球繞著太陽轉
    SCNNode *earthRotationNode = [SCNNode node];
    [_sunNode addChildNode:earthRotationNode];
    [earthRotationNode addChildNode:_earthGroupNode];
    
    
//    earth rotate sun
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 10.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [earthRotationNode addAnimation:animation forKey:@"earth rotation around sun"];
    
}

// 太陽自轉
- (void) addAnimationToSun {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    
    animation.duration = 10.0;
    
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    
    animation.repeatCount = FLT_MAX;
    
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.repeatCount = FLT_MAX;
    
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
    
}
- (void)addLight {
    
    SCNNode * lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.color = [UIColor redColor];
//    lightNode.light.type = SCNLightTypeOmni;
    [_sunNode addChildNode:lightNode];
    
    lightNode.light.attenuationEndDistance = 20.0;
    lightNode.light.attenuationStartDistance = 1.0;
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    {
        
        lightNode.light.color = [UIColor whiteColor]; // switch on
        _sunHaloNode.opacity = 0.5; // make the halo stronger
    }
    [SCNTransaction commit];
    
    _sunHaloNode = [SCNNode node];
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:25 height:25];
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun-halo.png";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
    _sunHaloNode.opacity = 0.9;
    [_sunNode addChildNode:_sunHaloNode];
}

#pragma lazy load

- (ARSession *)arSession{
    if(_arSession != nil)
    {
        return _arSession;
    }
    _arSession = [[ARSession alloc] init];
    return _arSession;
}

- (ARSCNView *)arSCNView
{
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _arSCNView.session = self.arSession;
    _arSCNView.automaticallyUpdatesLighting = YES;
    
    //初始化节点
    [self initNode];
    
    return _arSCNView;
}
@end

//首先設置一個地月結點
//然後設置一個黃道（地球繞著太陽轉的節點）
//添加動畫到黃道結點 （動）
//然後把黃道節點加到地月結點 （看到）
