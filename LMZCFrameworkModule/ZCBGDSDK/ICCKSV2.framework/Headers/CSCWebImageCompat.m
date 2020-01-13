/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageCompat.h"

#if !__has_feature(objc_arc)
    #error CSCWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag

#endif

#if !OS_OBJECT_USE_OBJC
    #error CSCWebImage need ARC for dispatch object
#endif
