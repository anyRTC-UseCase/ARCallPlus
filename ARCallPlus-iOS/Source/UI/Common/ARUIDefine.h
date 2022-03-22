//
//  ARUIDefine.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/18.
//

#ifndef ARUIDefine_h
#define ARUIDefine_h

#if DEBUG
#define ARLog(...) NSLog(__VA_ARGS__)
#else
#define ARLog(...)
#endif

#define Screen_Width        [UIScreen mainScreen].bounds.size.width
#define Screen_Height       [UIScreen mainScreen].bounds.size.height
#define Is_Iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_IPhoneX (Screen_Width >=375.0f && Screen_Height >=812.0f && Is_Iphone)
#define StatusBar_Height    (Is_IPhoneX ? (44.0):(20.0))
#define Bottom_SafeHeight   (Is_IPhoneX ? (34.0):(0))

#endif /* ARUIDefine_h */
